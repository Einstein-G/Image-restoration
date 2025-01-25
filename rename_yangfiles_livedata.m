clear
clc
main_path = 'Y:\Chris\CodeCentralization';
addpath(genpath(main_path))
cd(main_path)
tbi_path = [main_path, '\TBI\LiveDataMode'];
cd(tbi_path);
mkdir mod_files_livedata
exp_dir = [tbi_path, '\mod_files_livedata'];
cd(exp_dir)
image_dir = [tbi_path, '\3rd_16sample_Aug6'];
cd(image_dir);
files = dir('*.tif');
file_names = {};
for i = 1:length(files)
    image_name = files(i).name;
    file_names{end + 1} = image_name;
end
num_files = length(file_names);
new_file_names = cell(num_files, 1);
for i = 1:num_files
    file_name = file_names{i};
    file_name = ['int_ROI_', file_name];
    new_file_parts = strsplit(file_name, '_');
    rename_indices = zeros(length(new_file_parts), 1);
    count = 1;
    for j = 1:length(new_file_parts)
        part = new_file_parts{j};
        if contains(part, '755')
            rename_indices(8) = j;
            new_file_parts{j} = ['EX_', part(1:3)];
        elseif ~contains(part, 'ex') && j <= 8
            rename_indices(count) = j;
            count = count + 1;
        else
            count = count + 1;
            rename_indices(j) = count;
        end
    end
    file_name = [];
    for j = 1:length(new_file_parts)
        index = rename_indices(j);
        part = new_file_parts{index};
        file_name = [file_name, '_', part];
    end
    file_name = file_name(2:end);
    new_file_names{i} = file_name;
end
for i = 1:num_files
    source_file = file_names{i};
    source_path = [image_dir, '\', source_file];
    destination_file = new_file_names{i};
    destination_path = [exp_dir, '\', destination_file];
    copyfile(source_path, destination_path);
end