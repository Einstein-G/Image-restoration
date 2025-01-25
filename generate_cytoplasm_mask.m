function cytoplasm_mask_array =...
            generate_cytoplasm_mask(nadh_image_array, mask_info)

    %Generate cytoplasm mask for stack of epithelial images
    
    nadh_n = zeros(size(nadh_image_array));
    im_size = size(nadh_image_array, 1);
    size_small_object_removal = round(im_size / 50);
    sq_mask_border_size = round(im_size / 34);
    num_depths = size(nadh_image_array, 3);
    for i = 1:num_depths
        nadh_img = nadh_image_array(:, :, i);
        nadh_img_n = nadh_img - min(nadh_image_array(:));
        new_max_nadh = max(nadh_image_array(:)) - min(nadh_image_array(:));
        nadh_n(:, :, i) = nadh_img_n ./ new_max_nadh;
%         imwrite(double(nadh_n(:, :, i)),...
%             'test_nadh.tiff', 'Compression', 'none', 'WriteMode',...
%             'append');
    end
    gaussian_idxs = [];
    for i = 1:length(mask_info)
        if sum(contains(mask_info{i}, 'GAUSSIAN'))
            gaussian_idxs = horzcat(gaussian_idxs, i);
        end
    end
    gaussian_filtered_image_array = zeros(size(nadh_image_array));
    for i = 1:length(gaussian_idxs)
        gaussian_idx = gaussian_idxs(i);
        gaussian_info = mask_info{gaussian_idx};
        gaussian_low_cutoff = str2double(gaussian_info{2});
        gaussian_high_cutoff = str2double(gaussian_info{3});
        for j = 1:num_depths
            if i == 1
               nadh_img = nadh_n(:, :, j);
            else
               nadh_img = gaussian_filtered_image_array(:, :, j); 
            end
            gaussian_filtered_image_array(:, :, j) =...
                        gaussianbpf(nadh_img, gaussian_low_cutoff,...
                                                gaussian_high_cutoff);
        end
    end
    butterworth_idxs = [];
    for i = 1:length(mask_info)
        if sum(contains(mask_info{i}, 'BUTTERWORTH'))
            butterworth_idxs = horzcat(butterworth_idxs, i);
        end
    end
    if isempty(gaussian_idxs)
        gaussian_filtered_image_array = nadh_n;
    end
    butterworth_filtered_image_array = zeros(size(nadh_image_array));
    for i = 1:length(butterworth_idxs)
        butterworth_idx = butterworth_idxs(i);
        butterworth_info = mask_info{butterworth_idx};
        butterworth_low_cutoff = str2double(butterworth_info{2});
        butterworth_high_cutoff = str2double(butterworth_info{3});
        butterworth_order = str2double(butterworth_info{4});
        for j = 1:num_depths
            if i == 1
               gaussian_filtered_img =...
                                    gaussian_filtered_image_array(:, :, j);
            else
               gaussian_filtered_img =...
                                butterworth_filtered_image_array(:, :, j); 
            end
            butterworth_filtered_image_array(:, :, j) =...
                        butterworthbpf(gaussian_filtered_img,...
                        butterworth_low_cutoff, butterworth_high_cutoff,...
                        butterworth_order);
        end
    end
    if isempty(gaussian_idxs) && isempty(butterworth_idxs)
        L3 = nadh_n;
    elseif ~isempty(gaussian_idxs) && isempty(butterworth_idxs)
        L3 = gaussian_filtered_image_array;
    else
        L3 = butterworth_filtered_image_array;
    end
    L3_n = zeros(size(L3));
    for i = 1:num_depths
        im = L3(:, :, i);
        im_n = im - min(L3(:));
        new_max_im = max(L3(:)) - min(L3(:));
        L3_n(:, :, i) = im_n ./ new_max_im;
    end
    for i = 1:length(mask_info)
        if sum(contains(mask_info{i}, 'OTSU'))
            otsu_idx = i;
        end
    end
    otsu_info = mask_info{otsu_idx};
    num_threshold_levels = str2double(otsu_info{2});
    threshold_level = str2double(otsu_info{3});
    thresh_gray = multithresh(L3_n(:), num_threshold_levels);
    thresh_gray = thresh_gray(threshold_level);
    cytoplasm_mask_array = zeros(size(nadh_n));
    for i = 1:num_depths
        im = L3_n(:, :, i);
        mask_nadh = imbinarize(im, thresh_gray);
%         imwrite(double(logical(mask_nadh)),...
%             'test_cytoplasm_v2.tiff', 'Compression', 'none', 'WriteMode',...
%             'append');
        mask_nadh_small_objects_removed = miprmdebrisn(mask_nadh,...
                                            size_small_object_removal, 8);
        sq_mask = square_mask(im, sq_mask_border_size);
        cytoplasm_mask_array(:, :, i) = (mask_nadh_small_objects_removed .*...
                                    sq_mask);
%         imwrite(double(logical(cytoplasm_mask_array(:, :, i))),...
%             'test_cytoplasm_v2_all.tiff', 'Compression', 'none', 'WriteMode',...
%             'append');
    end
end