function experiment_parameters = save_parameters(exp_name, file_identifiers,...
                                                                data_type)
    current_directory = pwd;
    meta_data_directory = [current_directory, '\MetaData'];
    experiment_parameters = containers.Map;
    for i = 1:length(file_identifiers)
        parameter_map = containers.Map;
        file_identifier = file_identifiers{i};
        parameter_map('FileName') = file_identifier;
        file_identifier_parts = strsplit(file_identifier, '_');
        lambda_roi = file_identifier_parts{end};
        parameter_map('LambdaEx') = lambda_roi;
        [num_dims, dim_identifiers, dim_lengths, ~] =...
                                determine_dimensions(file_identifier);
        if num_dims >= 1
            dim_dimensions = pull_dim_dimensions(dim_lengths);
            parameter_map('Dimensions') = dim_identifiers;
            parameter_map('DimensionLengths') = dim_dimensions;
        end
        cd(meta_data_directory);
        [~, channel_names, num_seqs, ~] =...
                                    organize_channels(file_identifier);
        channel_gains = gain_search(file_identifier, channel_names);
        parameter_map('DetectorNames') = keys(channel_gains);
        parameter_map('DetectorGains') = values(channel_gains);
        parameter_map('NumSeqs') = num_seqs;
        keep_power = power_search(file_identifier, lambda_roi);
        parameter_map('PowerPercents') = keep_power;
        [column_length, row_length] = pull_im_dims_pixels(file_identifier);
        parameter_map('ImageSize') = [column_length, row_length];
        [column_length_meters, row_length_meters] =...
                                    pull_im_dims_meters(file_identifier);
        parameter_map('ImageLength') = [column_length_meters,...
                                                        row_length_meters];
        objective_magnification = pull_magnification(file_identifier);
        parameter_map('Magnification') = objective_magnification;
        frame_avg = pull_frame_avg(file_identifier);
        parameter_map('FrameAvg') = frame_avg;
        frame_acc = pull_frame_acc(file_identifier);
        parameter_map('FrameAcc') = frame_acc;
        line_avg = pull_line_avg(file_identifier);
        parameter_map('LineAvg') = line_avg;
        line_acc = pull_line_acc(file_identifier);
        parameter_map('LineAcc') = line_acc;
        if strcmp(data_type, 'spec')
            lambda_start = pull_lambda_start(file_identifier);
            parameter_map('LambdaStart') = lambda_start;
            lambda_end = pull_lambda_end(file_identifier);
            parameter_map('LambdaEnd') = lambda_end;
            lambda_bandwidth = pull_lambda_bandwidth(file_identifier);
            parameter_map('LambdaBandwidth') = lambda_bandwidth;
            lambda_stepsize = pull_lambda_stepsize(file_identifier);
            parameter_map('LambdaStepSize') = lambda_stepsize;
            lambda_stepcount = pull_lambda_stepcount(file_identifier);
            parameter_map('LambdaStepCount') = lambda_stepcount;
        end
        cd(current_directory)
        save_table = cell2table(values(parameter_map), 'VariableNames',...
                                                    keys(parameter_map));
        identifier_length = length(file_identifier);
        if identifier_length > 31
            first_name_index = identifier_length - 31 + 1;
            file_identifier_abridged = file_identifier(first_name_index:end);
            writetable(save_table, [exp_name, '_', data_type, '.xlsx'],...
                                        'Sheet', file_identifier_abridged);
        else
            writetable(save_table, [exp_name, '_', data_type, '.xlsx'],...
                                                'Sheet', file_identifier);
        end
        experiment_parameters(file_identifier) = save_table;
        clear parameter_map
    end
end