function [image_array_coregistered] = coregister_wavelengths(roi_names,...
                        file_identifiers, image_array,target_wavelength,...
                                                        reference_channel)
    % Coregister 2D and 3D (depth) data
    
    image_array_coregistered = containers.Map;
    for i = 1:length(roi_names)
        roi = roi_names{i};
        keep_identifiers = {};
        for j = 1:length(file_identifiers)
            file_identifier = file_identifiers{j};
            if contains(file_identifier, roi)
                keep_identifiers{end + 1} = file_identifier;
            end
        end
        num_lambdas = length(keep_identifiers);
        if num_lambdas == 1
            disp(['ROI ', roi, ' only has 1 wavelength; no'...
                                                ' coregistration needed'])
            file_identifier = cell2mat(keep_identifiers);
            image_array_coregistered(file_identifier) =...
                                            image_array(file_identifier);
        else
            shift_identifiers = {};
            for j = 1:num_lambdas
                keep_identifier = keep_identifiers{j};
                if contains(keep_identifier, target_wavelength)
                    ref_identifier = keep_identifier;
                else
                    shift_identifiers{end + 1} = keep_identifier;
                end
            end
            [~, ref_detectors, ~, ~] = organize_channels(ref_identifier);
            ref_channel_idx = find(contains(ref_detectors,...
                                                    reference_channel));
            if isempty(ref_channel_idx)
                disp(['The specified detector for coregistration is ',...
                                                            'inactive'])
            end
            ref_images = image_array(ref_identifier);
%             ref_images = ref_images(:, :, :, :, 1:end - 2); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             image_array(ref_identifier) = ref_images; %%%%%%%%%%%%%%%%%%%%%%%%%%%
            ref_channel_image_array = pull_ref_channel_images(ref_images,...
                                                        ref_channel_idx);
            depth_shift_array = containers.Map;
            translation_shift_array = containers.Map;
            for j = 1:length(shift_identifiers)
                shift_identifier = shift_identifiers{j};
                [~, shift_detectors, ~, ~] =...
                                    organize_channels(shift_identifier);
                shift_channel_idx = find(contains(shift_detectors,...
                                                    reference_channel));
                shift_images = image_array(shift_identifier);
%                 if j == 1
%                     shift_images = shift_images(:, :, :, :, 2:end - 1); %%%%%%%%%%%%%%%%%%%%%%%%%
%                 else
%                     shift_images = shift_images(:, :, :, :, 3:end); %%%%%%%%%%%%%%%%%%%%%%%
%                 end
%                 image_array(shift_identifier) = shift_images; %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                shift_channel_image_array = pull_ref_channel_images(shift_images,...
                                                        shift_channel_idx);
                [lateral_shift, depth_shift] = ...
                    generate_coregistration_shift(shift_identifier,...
                        ref_channel_image_array, shift_channel_image_array);
                depth_shift_array(shift_identifier) = depth_shift;
                translation_shift_array(shift_identifier) = lateral_shift;
            end
            coregistered_roi_image_array =...
                    generate_roi_coregistration_array(image_array,...
                    ref_identifier, shift_identifiers, depth_shift_array,...
                    translation_shift_array);
            coregistered_roi_image_array_keys =...
                                        keys(coregistered_roi_image_array);
            num_keys = length(coregistered_roi_image_array_keys);
            for j = 1:num_keys
                key = coregistered_roi_image_array_keys{j};
                image_array_coregistered(key) =...
                                        coregistered_roi_image_array(key);
            end
        end
    end
end