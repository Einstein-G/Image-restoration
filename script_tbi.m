clear
clc
exp_name = 'mod_files';
addpath(genpath('Y:\Chris\CodeCentralization'))
main_path = 'Y:\Chris\CodeCentralization\TBI';
addpath(genpath(main_path))
cd(main_path)
mkdir(exp_name)
exp_dir = [main_path, '\', exp_name];
cd(exp_dir)
intensity_file_names = load_files('spec');
unique_rois = determine_rois(intensity_file_names);
file_identifiers = determine_roi_lambdas(intensity_file_names,...
                                            unique_rois);