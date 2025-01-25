function file_name_array = generate_file_name_array(file_identifiers)
    current_directory = pwd;
    meta_data_directory = [current_directory, '\MetaData'];
    file_name_array = containers.Map;
    for i = 1:length(file_identifiers)
        file_identifier = file_identifiers{i};
        [num_dims, dim_identifiers, dim_lengths, dim_name_array] =...
                                determine_dimensions(file_identifier);
        cd(meta_data_directory);
        [channel_array, channel_names, num_seqs, num_detectors] =...
                                    organize_channels(file_identifier);
        cd(current_directory)
        file_name_array_temp = {};
        for j = 1:num_seqs
            for k = 1:num_detectors
                if num_dims == 0
                    file_name_array_temp{j, k} = [file_identifier,...
                        '_RAW_', channel_array{j, k}, '.tif'];
                else
                    dim1_size = size(dim_name_array, 1);
                    dim2_size = size(dim_name_array, 2);
                    for m = 1:dim1_size
                        for n = 1:dim2_size
                            file_name_array_temp{j, k, m, n} = ...
                                [file_identifier, '_',...
                                dim_name_array{m, n}, '_RAW_'...
                                channel_array{j, k}, '.tif'];
                        end
                    end
                end
            end
        end
        file_name_array(file_identifier) = file_name_array_temp;
    end
    cd(current_directory)
end