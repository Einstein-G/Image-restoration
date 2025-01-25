function downsampled_array = downsample_array(array, downsample_factor)
    array_size = size(array);
    im_size_row = array_size(1);
    im_size_col = array_size(2);
    new_im_size_row = im_size_row / downsample_factor;
    new_im_size_col = im_size_col / downsample_factor;
    new_array_size = [new_im_size_row, new_im_size_col, array_size(3:end)];
    pixel_idxs_begin_row = (0:downsample_factor:im_size_row) + 1;
    pixel_idxs_end_row = (0:downsample_factor:im_size_row) + 2;
    pixel_idxs_begin_col = (0:downsample_factor:im_size_col) + 1;
    pixel_idxs_end_col = (0:downsample_factor:im_size_col) + 2;
    reshape_dim = prod(array_size(3:end));
    downsampled_array_temp = zeros(new_im_size_row, new_im_size_col,...
                                        reshape_dim);
    for i = 1:new_im_size_row
        row_begin = pixel_idxs_begin_row(i);
        row_end = pixel_idxs_end_row(i);
        for j = 1:new_im_size_col
            col_begin = pixel_idxs_begin_col(j);
            col_end = pixel_idxs_end_col(j);
            window = array(row_begin:row_end, col_begin:col_end, :);
            new_pix = mean(window, [1 2]);
            downsampled_array_temp(i, j, :) = new_pix;
        end
    end
    downsampled_array = reshape(downsampled_array_temp, new_array_size);
end