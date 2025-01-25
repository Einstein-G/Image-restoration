clear
clc
main_path = 'X:\Chris\CodeCentralization';
addpath(genpath(main_path))
project = 'TBI';
project_path = [main_path, '\', project];
exp_name = 'mod_files';
cd(project_path)
mkdir(exp_name)
exp_dir = [project_path, '\', exp_name];
cd(exp_dir)
data_type = 'int';
file_identifiers = determine_unique_file_identifiers(data_type)
% fprintf('Data summary\nImaging type\t%s\nUnique ROIs\t',data_type);
% display(file_identifiers);display('excitation wavelengths')
% file_name_array = generate_file_name_array(file_identifiers);