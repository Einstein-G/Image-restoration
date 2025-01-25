function shg_mask_array = generate_shg_mask(shg_image_array,...
                                                    mask_info)

    %Generate SHG mask for a stack of epithelial images
    
    shg_n = zeros(size(shg_image_array));
    im_size = size(shg_image_array, 1);
    size_small_object_removal = round(im_size / 50);
    num_depths = size(shg_image_array, 3);
    for i = 1:num_depths
        shg_img = shg_image_array(:, :, i);
        shg_img_n = shg_img - min(shg_image_array(:));
        new_max_shg = max(shg_image_array(:)) - min(shg_image_array(:));
        shg_n(:, :, i) = shg_img_n ./ new_max_shg;
%         imwrite(shg_n(:, :, i),...
%                 'shg.tiff', 'Compression',...
%                 'none', 'WriteMode', 'append');
    end
    for i = 1:length(mask_info)
        if sum(contains(mask_info{i}, 'OTSU'))
            otsu_idx = i;
        end
    end
    otsu_info = mask_info{otsu_idx};
    num_threshold_levels = str2double(otsu_info{2});
    threshold_level = str2double(otsu_info{3});
    thresh_gray = multithresh(shg_n(:), num_threshold_levels);
    thresh_gray = thresh_gray(threshold_level);
    shg_mask_array = zeros(size(shg_n));
    for i = 1:num_depths
        shg_img_n = shg_n(:, :, i);
        shg_mask_img = imbinarize(shg_img_n, thresh_gray);
        shg_mask_img_inverted =...
                                    ~shg_mask_img;
        shg_mask_img_inverted_small_objects_removed =...
                                    miprmdebrisn(shg_mask_img_inverted,...
                                    size_small_object_removal, 8);
        shg_mask_array(:, :, i) = shg_mask_img_inverted_small_objects_removed;
%         imwrite(shg_mask_img_inverted_small_objects_removed,...
%                 'collagen_mask_v2.tiff', 'Compression',...
%                 'none', 'WriteMode', 'append');
    end
end