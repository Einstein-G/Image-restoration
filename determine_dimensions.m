function [num_dims, dim_identifiers, dim_lengths, dim_name_array] =...
                                            determine_dimensions(file_name)
    file_name_parts = strsplit(file_name, '_');
    lambda = file_name_parts{end};
    all_files = dir;
    dim_expression = ['\w*EX_', lambda, '_(\w*)_RAW'];
    dims_all = {};
    dim_identifiers_all = {};
    dim_lengths_all = {};
    count = 0;
    for i = 1:length(all_files)
        if contains(all_files(i).name, file_name)
            count = count + 1;
            dim_cell = regexp(all_files(i).name, dim_expression, 'tokens');
            if isempty(dim_cell)
                num_dims = 0;
            else
                dim_string = cell2mat(dim_cell{1}(end));
                dims_all{count} = dim_string;
                dim_string_parts = strsplit(dim_string, '_');
                num_parts = length(dim_string_parts);
                for j = 1:length(dim_string_parts)
                    part = dim_string_parts{j};
                    part_text = [];
                    part_numerical = [];
                    for k = 1:length(part)
                        if isstrprop(part(k), 'alpha')
                            part_text = [part_text, part(k)];
                        else
                            part_numerical = [part_numerical, part(k)];
                        end
                    end
                    dim_identifiers_all{count, j} = part_text;
                    dim_lengths_all{count, j} = part_numerical;
                end
            end
        end
    end
    [num_rows, num_dims] = size(dim_identifiers_all);
    dim_identifiers = cell(1, num_dims);
    dim_lengths = cell(1, num_dims);
    for i = 1:num_dims
        dim_identifiers{1, i} = cell2mat(unique(dim_identifiers_all(:, i),...
                                            'stable'));
        dim_lengths{1, i} = unique(dim_lengths_all(:, i),...
                                            'stable');
    end
    dim_dimensions = flip(pull_dim_dimensions(dim_lengths));
    dims_size = [dim_dimensions, 1];
    unique_dims_all = unique(dims_all, 'stable');
    if num_dims >= 1
        dim_name_array = reshape(unique_dims_all, dims_size);
        dim_name_array = squeeze(dim_name_array);
    else
        dim_name_array = dim_lengths;
    end
end