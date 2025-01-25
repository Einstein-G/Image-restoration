function [translation_shift, depth_shift] =...
                        generate_coregistration_shift(file_identifier,...
                                                ref_images, shift_images)
    
    %Calculate the coregistration translation between two channels of 
    %acquisition
    
    num_array_dims = length(shift_images);
    if num_array_dims >= 3
        shift_images_noseq = squeeze(mean(shift_images, 3));
        ref_images_noseq = squeeze(mean(ref_images, 3));
    else
        shift_images_noseq = shift_images;
        ref_images_noseq = ref_images;
    end
    row_length = size(shift_images, 1);
    column_length = size(shift_images, 2);
    coregistration_window_column_length = round(column_length .* 0.4);
    coregistration_window_row_length = round(row_length .* 0.4);
    [~, dim_identifiers, dim_lengths, ~] =...
                                determine_dimensions(file_identifier);
    if isempty(dim_identifiers)
        [x_shift, y_shift] = calc_shift_2d(ref_images_noseq,...
                                shift_images_noseq, row_length,...
                                column_length,...
                                coregistration_window_row_length,...
                                coregistration_window_column_length);
        translation_shift = [x_shift, y_shift];
        depth_shift = 0;
    elseif contains(cell2mat(dim_identifiers), 'z')
        shift_images_noseq = shift_images_noseq(:, :, :);
        ref_images_noseq = ref_images_noseq(:, :, :);
        z_index = strfind(cell2mat(dim_identifiers), 'z');
        num_depths = length(dim_lengths{z_index});
%         num_depths = length(dim_lengths{z_index}) - 2; %%%%%%%%%%%%%%%%%
        shift_images_noseq_depths = shift_images_noseq(:, :, 1:num_depths);
        ref_images_noseq_depths = ref_images_noseq(:, :, 1:num_depths);
        shift_os_index = determine_depth_ref_os(shift_images_noseq_depths);
%         shift_os_index = 4;
        [translation_shift, depth_shift] =...
                                calc_shift_depth(ref_images_noseq_depths,...
                                shift_images_noseq_depths, row_length,...
                                column_length,...
                                coregistration_window_row_length,...
                                coregistration_window_column_length,...
                                shift_os_index);
    else
        translation_shift = [0, 0];
        depth_shift = 0;
    end
end