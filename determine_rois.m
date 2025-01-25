function roi_names = determine_rois(image_names)
    num_images = length(image_names);
    roi_names_all = cell(num_images, 1);
    for i = 1:num_images
        image_name = image_names{i};
        name_parts = strsplit(image_name, '_');
        roi_name_limits = zeros(1, 2);
        for j = 1:length(name_parts)
            if strcmp(name_parts{j}, 'ROI')
                roi_name_limits(1) = j + 1;
            elseif strcmp(name_parts{j}, 'EX')
                roi_name_limits(2) = j - 1;
            end
        end
        if roi_name_limits(1) == roi_name_limits(2)
            index = roi_name_limits(1);
            roi_names_all{i} = name_parts{index};
        else
            roi_name = [];
            roi_name_indices = roi_name_limits(1):roi_name_limits(2);
            for j = 1:length(roi_name_indices)
                index = roi_name_indices(j);
                roi_name = [roi_name, '_', name_parts{index}];
            end
            roi_name = roi_name(2:end);
            roi_names_all{i} = roi_name;
        end
    end
    roi_names = unique(roi_names_all);
end