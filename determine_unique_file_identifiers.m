function [file_identifiers, unique_rois] =...
                            determine_unique_file_identifiers(data_type)
    intensity_file_names = load_files([data_type, '_']);
    unique_rois = determine_rois(intensity_file_names);
    file_identifiers = determine_roi_lambdas(intensity_file_names,...
                                                unique_rois);
    for i = 1:length(file_identifiers)
        file_identifiers{i} = [data_type, '_', file_identifiers{i}];
    end
end