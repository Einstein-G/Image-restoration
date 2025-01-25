function mask_container = generate_masks_epithelium(roi_names,...
                                    file_identifiers, image_array,...
                                                    mask_info_container)
    
    %Generate masks for epithelial image stacks
    
    mask_container = containers.Map;
    for i = 1:length(roi_names)
        roi_name = roi_names{i};
        roi_file_identifiers = {};
        for j = 1:length(file_identifiers)
            file_identifier = file_identifiers{j};
            if contains(file_identifier, roi_name)
                roi_file_identifiers{end + 1} = file_identifier;
            end
        end
        mask_info_container_keys = keys(mask_info_container);
        roi_mask_container = containers.Map;
        for j = 1:length(mask_info_container)
            key = mask_info_container_keys{j};
            mask_info = mask_info_container(key);
            for k = 1:length(mask_info)
                if sum(contains(mask_info{k}, 'CHANNEL'))
                    channel_info_idx = k;
                end
            end
            channel_info = mask_info{channel_info_idx};
            mask_info_wavelength = channel_info{2};
            mask_info_detector = channel_info{3};
            for k = 1:length(roi_file_identifiers)
                roi_file_identifier = roi_file_identifiers{k};
                if contains(roi_file_identifier, mask_info_wavelength)
                    mask_file_identifier = roi_file_identifier;
                end
            end
            [~, mask_file_identifier_detectors, ~, ~] =...
                                organize_channels(mask_file_identifier);
            mask_file_channel_idx =...
                        find(contains(mask_file_identifier_detectors,...
                                                    mask_info_detector));
            mask_file_identifier_images = image_array(mask_file_identifier);
            mask_image_array =...
                    pull_ref_channel_images(mask_file_identifier_images,...
                                                    mask_file_channel_idx);
            mask_image_array = squeeze(mask_image_array);
            if strcmp(key, 'NADH')
                mask_array = generate_cytoplasm_mask(mask_image_array,...
                                                    mask_info);
            elseif strcmp(key, 'SHG')
                mask_array = generate_shg_mask(mask_image_array,...
                                                    mask_info);
            end
            roi_mask_container(key) = mask_array;
            new_key = [roi_name, '_', key];
            mask_container(new_key) = mask_array;
        end
        final_mask = ones(size(mask_array));
        for j = 1:length(roi_mask_container)
            key = mask_info_container_keys{j};
            mask_array = roi_mask_container(key);
            final_mask = final_mask .* mask_array;
        end
        mask_container([roi_name, '_ALL']) = final_mask;
    end
end