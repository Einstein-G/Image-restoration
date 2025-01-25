clear
clc
main_path = 'Y:\Chris\CodeCentralization';
addpath(genpath(main_path))
cd(main_path)
tbi_path = [main_path, '\TBI\LiveDataMode'];
cd(tbi_path);
exp_dir = [tbi_path, '\mod_files_livedata_sequences'];
cd(exp_dir)
mkdir MetaData
image_dir = [tbi_path, '\New_Injury_06.22\MetaData'];
cd(image_dir);
files = dir('*.xml');
file_names = {};
for i = 1:length(files)
    image_name = files(i).name;
    if contains(image_name, 'Sequence 001')
        file_names{end + 1} = image_name;
    end
end
num_files = length(file_names);
new_file_names = cell(num_files, 1);
for i = 1:num_files
    file_name = file_names{i};
    prefix_parts = strsplit(file_name, '_Int');
    prefix = prefix_parts{1};
    prefix = strrep(prefix, ' ', '_');
    file_name_intermediate = ['Int', prefix_parts{2}];
    roi_break = strsplit(file_name_intermediate, 'ROI');
    file_name_w_prefix = [roi_break{1}, 'ROI_', prefix, roi_break{2}];
    after_lambda_parts = strsplit(file_name_w_prefix, 'EX_');
    after_lambda = after_lambda_parts{2};
    dimension_parts = strsplit(after_lambda, '_');
    lambda = dimension_parts{1};
    check_dims_array = zeros(1, length(dimension_parts));
    for j = 1:length(dimension_parts)
        part = dimension_parts{j};
        if isstrprop(part(1), 'alpha')
            check_dims_array(j) = 1;
        else
            check_dims_array(j) = 0;
        end
    end
    check_dims_indxs = find(check_dims_array);
    keep_dimension_parts = dimension_parts(check_dims_indxs);
    keep_dimensions = strjoin(keep_dimension_parts, '_');
    file_name_new = [after_lambda_parts{1}, 'EX_', lambda, '_',...
                                                        keep_dimensions];
    if strcmp(file_name_new(end), '_')
        file_name_new = [file_name_new(1:end - 1), '.xml'];
    end
    new_file_names{i} = file_name_new;
end
for i = 1:num_files
    source_file = file_names{i};
    source_path = [image_dir, '\', source_file];
    destination_file = new_file_names{i};
    destination_path = [exp_dir, '\MetaData\', destination_file];
    copyfile(source_path, destination_path);
end