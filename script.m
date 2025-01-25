clear
clc
exp_name = '20220321_LEEP';
main_path = 'Y:\Chris\CodeCentralization\Cervix';
addpath(genpath(main_path))
cd(main_path)
mkdir(exp_name)
exp_dir = [main_path, '\', exp_name];
cd(exp_dir)
intensity_file_names = load_files('int');
unique_rois = determine_rois(intensity_file_names);
file_identifiers = determine_roi_lambdas(intensity_file_names,...
                                            unique_rois);