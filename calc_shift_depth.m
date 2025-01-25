function [translation_shift_array, depth_shift] =...
                                calc_shift_depth(ref_image_array,...
                                shift_image_array, im_size_row,...
                                im_size_column,...
                                coregistration_window_row_length,...
                                coregistration_window_column_length,...
                                depth_ref_os_index)
    
    %Calculate array of translational shift values; Determine if a shift
    % in depth is necessary
    
    depth_ref_img = shift_image_array(:, :, depth_ref_os_index);
    num_depths = size(ref_image_array, 3);
    depth_check_range = ceil(num_depths .* 0.1) + 1;
    if depth_ref_os_index - depth_check_range < 1
        depth_check_start = 1;
    else
        depth_check_start = depth_ref_os_index - depth_check_range;
    end
    if depth_ref_os_index + depth_check_range > num_depths
        depth_check_end = num_depths;
    else
        depth_check_end = depth_ref_os_index + depth_check_range;
    end
    depth_check_array = depth_check_start:depth_check_end;
    depth_correlation_array = zeros(1, length(depth_check_array));
    for i = 1:length(depth_check_array)
        depth_check_idx = depth_check_array(i);
        depth_check_img = ref_image_array(:, :, depth_check_idx);
        depth_correlation = normxcorr2(depth_ref_img, depth_check_img);
        coregistration_mask = zeros(size(depth_correlation));
        mask_start_row = im_size_row - coregistration_window_row_length;
        mask_end_row = im_size_row + coregistration_window_row_length;
        mask_start_column = im_size_column -...
                                    coregistration_window_column_length;
        mask_end_column = im_size_column +...
                                    coregistration_window_column_length;
        coregistration_mask(mask_start_row:mask_end_row,...
                                    mask_start_column:mask_end_column) = 1;
        depth_correlation_masked = depth_correlation.*coregistration_mask;
        depth_correlation_array(i) = max(depth_correlation_masked(:));
    end
    [~, max_depth_correlation_idx] = max(depth_correlation_array);
    depth_shift = depth_check_array(max_depth_correlation_idx) -...
                                                        depth_ref_os_index;
    if depth_shift > 0
        shift_imgs_shifted = shift_image_array(:, :, 1:(end-depth_shift));
        ref_imgs_shifted = ref_image_array(:, :, (1+depth_shift):end);
    elseif depth_shift < 0
        shift_imgs_shifted = shift_image_array(:, :, (1+abs(depth_shift)):end);
        ref_imgs_shifted = ref_image_array(:, :, 1:(end+depth_shift));
    else
        ref_imgs_shifted = ref_image_array;
        shift_imgs_shifted = shift_image_array;
    end
    num_depths_shifted = size(ref_imgs_shifted, 3);
    shift_stack = zeros(num_depths_shifted, 2);
    for i = 1:num_depths_shifted
        ref_img = ref_imgs_shifted(:, :, i);
        shift_img = shift_imgs_shifted(:, :, i);
        if sum(nonzeros(shift_img))~=0 && sum(nonzeros(ref_img))~=0
            [x_shift, y_shift] = calc_shift_2d(ref_img, shift_img,...
                im_size_row, im_size_column,...
                coregistration_window_row_length,...
                coregistration_window_column_length);
        else
            x_shift = 0;
            y_shift = 0;
        end
        shift_stack(i, 1) = x_shift;
        shift_stack(i, 2) = y_shift;
    end
    total_shift_array = sum(abs(shift_stack), 2);
    [min_shift, ~] = min(total_shift_array);
    median_shift = median(total_shift_array);
%     shift_limit = ((median_shift - min_shift)*2) + min_shift;
%     shift_limit = 3*min_shift;
    shift_limit = 80;
    shift_idx_array = total_shift_array < shift_limit;
    keep_shift = zeros(sum(shift_idx_array), 3);
    depth_array = 1:num_depths_shifted;
    count = 0;
    for i = 1:length(total_shift_array)
        if shift_idx_array(i)
            count = count + 1;
            keep_shift(count, 1) = shift_stack(i, 1);
            keep_shift(count, 2) = shift_stack(i, 2);
            keep_shift(count, 3) = i;
        end
    end
    x_fit = polyfit(keep_shift(:, 3), keep_shift(:, 1), 1);
    y_fit = polyfit(keep_shift(:, 3), keep_shift(:, 2), 1);
    x_shift = round(polyval(x_fit, depth_array))';
    y_shift = round(polyval(y_fit, depth_array))';
    translation_shift_array = [x_shift y_shift];
end