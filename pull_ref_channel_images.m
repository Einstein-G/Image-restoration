function ref_channel_images = pull_ref_channel_images(image_array,...
                        ref_channel_idx)
    %Pull images from the proper data channel while maintaining image_array
    %dimensionality
    channel_dim = 4;
    num_array_dims = length(size(image_array));
    dim_idx_array = 1:num_array_dims;
    permute_dimensions_array = [channel_dim,...
                            dim_idx_array(dim_idx_array ~= channel_dim)];
    image_array_permuted = permute(image_array, permute_dimensions_array);
    image_array_permuted_size = size(image_array_permuted);
    num_channels = image_array_permuted_size(1);
    non_channel_dims = prod(image_array_permuted_size(2:end));
    image_array_permuted_reshaped = reshape(image_array_permuted,...
                                        [num_channels, non_channel_dims]);
    image_array_ref_channel_reshaped =...
                        image_array_permuted_reshaped(ref_channel_idx, :);
    ref_channel_images = reshape(image_array_ref_channel_reshaped,...
                                        image_array_permuted_size(2:end));
end