function [calibrated_image_array, calibrated_frame_array] =...
                    generate_image_array(file_name_array, power_array,...
                                                        power_array_ref)
    current_directory = pwd;
    meta_data_directory = [current_directory, '\MetaData'];
    file_identifiers = keys(file_name_array);
    calibrated_image_array = containers.Map;
    calibrated_frame_array = containers.Map;
    for i = 1:length(file_identifiers)
        file_identifier = file_identifiers{i};
        file_names_roi = file_name_array(file_identifier);
        file_name_parts = strsplit(file_identifier, '_');
        lambda_roi = file_name_parts{end};
        power_roi = double(str2sym(['power_array.lam',...
                                                    num2str(lambda_roi)]));
        power_ref_roi = double(str2sym(['power_array_ref.lam',...
                                                    num2str(lambda_roi)]));
        [num_dims, dim_identifiers, dim_lengths, dim_name_array] =...
                                determine_dimensions(file_identifier);
        cd(meta_data_directory);
        [channel_array, channel_names, num_seqs, num_detectors] =...
                                    organize_channels(file_identifier);
        channel_gains = gain_search(file_identifier, channel_names);
        keep_power = power_search(file_identifier, lambda_roi);
%         keep_power_array = generate(power_roi, power_roi_ref,...
%                                 keep_power,)
        disp('sheesh')
    end
end