function file_identifiers = determine_roi_lambdas(image_names,...
                                                    roi_names)
    file_identifiers = {};
    for i = 1:length(roi_names)
        roi = ['ROI_', roi_names{i}];
        lambdas = {};
        for j = 1:length(image_names)
            image_name = image_names{j};
            if contains(image_name, roi)
                name_parts = strsplit(image_name, '_');
                for k = 1:length(name_parts)
                    if strcmp(name_parts{k}, 'EX')
                        lambdas{end + 1} = name_parts{k + 1};
                    end
                end
            end
        end
        unique_lambdas = unique(lambdas);
        for j = 1:length(unique_lambdas)
            lambda = unique_lambdas{j};
            file_identifiers{end + 1} = [roi, '_EX_', lambda];
        end
    end
end