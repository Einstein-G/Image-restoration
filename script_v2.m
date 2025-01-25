clear
clc
main_path = 'Y:\Chris\CodeCentralization';
addpath(genpath(main_path))
project = 'GrekaCells';
project_path = [main_path, '\', project];
exp_name = '20210707_Min6Cells';
power_array_ref = struct('lam755', 2:2:10, 'lam860', 2:2:8,...
                                            'lam720', 2:2:8);
power_array = struct('lam755', [10, 20, 30, 40, 50], 'lam860', [16, 32,...
                    48, 64], 'lam720', [12 24 36 48]);
downsample_factor = 2;
cd(project_path)
mkdir(exp_name)
exp_dir = [project_path, '\', exp_name];
cd(exp_dir)
data_type = 'int';
[file_identifiers, roi_names] = determine_unique_file_identifiers(data_type);
[file_name_array, calibrated_image_array, calibrated_frame_array] = generate_arrays(...
                            file_identifiers, power_array, power_array_ref);
[calibrated_image_array_downsampled, calibrated_frame_array_downsampled] =...
                            generate_downsampled_arrays(file_identifiers,...
                            calibrated_image_array,...
                            calibrated_frame_array, downsample_factor);
experiment_parameters = save_parameters(exp_name, file_identifiers, data_type);