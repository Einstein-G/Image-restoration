function [x_shift, y_shift] = calc_shift_2d(ref_image, shift_image,...
                                im_size_row, im_size_column,...
                                coregistration_window_row_length,...
                                coregistration_window_column_length)
    
    % Calculate image translation

    correlation_map = normxcorr2(shift_image, ref_image);
    correlation_map_mask = zeros(size(correlation_map));
    mask_start_row = im_size_row - coregistration_window_row_length;
    mask_end_row = im_size_row + coregistration_window_row_length;
    mask_start_column = im_size_column - coregistration_window_column_length;
    mask_end_column = im_size_column + coregistration_window_column_length;
    correlation_map_mask(mask_start_row:mask_end_row,...
                                mask_start_column:mask_end_column) = 1;
    correlation_map_masked = correlation_map.*correlation_map_mask;
    if max(correlation_map_masked(:)) == 0
        y = 0;
        x = 0;
    else
        [y, x] = find(correlation_map_masked ==...
                                    max(correlation_map_masked(:)));
    end
    y_shift = y - im_size_column;
    x_shift = x - im_size_row;
end