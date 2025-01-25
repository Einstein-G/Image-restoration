function [file_name_array, calibrated_image_array, calibrated_frame_array] =...
                    generate_arrays(file_identifiers, power_array,...
                                                        power_array_ref)
    current_directory = pwd;
    meta_data_directory = [current_directory, '\MetaData'];
    file_name_array = containers.Map;
    calibrated_image_array = containers.Map;
    calibrated_frame_array = containers.Map;
    for i = 1:length(file_identifiers)
        file_identifier = file_identifiers{i};
        file_identifier_parts = strsplit(file_identifier, '_');
        lambda_roi = file_identifier_parts{end};
        power_roi = double(str2sym(['power_array.lam',...
                                                    num2str(lambda_roi)]));
        power_roi_ref = double(str2sym(['power_array_ref.lam',...
                                                    num2str(lambda_roi)]));
        [num_dims, dim_identifiers, dim_lengths, dim_name_array] =...
                                determine_dimensions(file_identifier);
        cd(meta_data_directory);
        [channel_array, channel_names, num_seqs, num_detectors] =...
                                    organize_channels(file_identifier);
%         num_seqs=num_seqs/2;
        channel_gains = gain_search(file_identifier, channel_names);
        keep_power = power_search(file_identifier, lambda_roi);
        [column_length, row_length] = pull_im_dims_pixels(file_identifier);
        cd(current_directory)
        power_dim_length = determine_power_dim_length(dim_identifiers,...
                                                            dim_lengths);
        keep_power_array = generate_keep_power_array(power_roi,...
                            power_roi_ref, keep_power, power_dim_length);
        file_name_array_temp = {};
        if num_dims == 0
            calibrated_frame_array_temp = zeros(row_length,...
                column_length, num_seqs, num_detectors);
        else
            calibrated_frame_array_temp = zeros(row_length,...
                column_length, num_seqs, num_detectors,...
                size(dim_name_array, 1), size(dim_name_array, 2));
        end
        for j = 1:num_seqs
            for k = 1:num_detectors
                channel = channel_names{k};
                gain = channel_gains(channel);
                if num_dims == 0
                    file_name_temp = [file_identifier, '_RAW_',...
                                            channel_array{j, k}, '.tif'];
                    file_name_array_temp{j, k} = file_name_temp;
                    temp_im = double(imread(file_name_temp));
                    temp_im_calibrated = transferfnSP8(temp_im, gain,...
                                                keep_power_array);
                    calibrated_frame_array_temp(:, :, j, k) =...
                                                        temp_im_calibrated;
                else
                    dim1_size = size(dim_name_array, 1);
                    dim2_size = size(dim_name_array, 2);
                    for m = 1:dim1_size
                        for n = 1:dim2_size
                            if dim1_size == power_dim_length
                                power = keep_power_array(m);
                            else
                                power = keep_power_array(n);
                            end
                            file_name_temp = [file_identifier, '_',...
                                        dim_name_array{m, n}, '_RAW_',...
                                        channel_array{j, k}, '.tif'];
                            file_name_array_temp{j, k, m, n} = ...
                                file_name_temp;
                            temp_im = double(imread(file_name_temp));
                            temp_im_calibrated = transferfnSP8(temp_im,...
                                                        gain, power);
                            calibrated_frame_array_temp(:, :, j, k, m, n) =...
                                                        temp_im_calibrated;
                        end
                    end
                end
            end
        end
        file_name_array(file_identifier) = file_name_array_temp;
        calibrated_frame_array(file_identifier) =...
                                            calibrated_frame_array_temp;
        calibrated_image_array_temp = mean(calibrated_frame_array_temp, 3);
        calibrated_image_array(file_identifier) =...
                                            calibrated_image_array_temp;
    end
    cd(current_directory)
end