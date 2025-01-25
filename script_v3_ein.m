clear
clc
close all
main_path = 'X:\Einstein\CodeCentralization';
addpath(genpath(main_path))
project = 'Celegans';%'TBI';%'TBI\LiveDataMode'; %'RatEpithelium'; %'GrekaCells';
project_path = [main_path, '\', project];
exp_name = 'Treated3';%'mod_files';%'mod_files_livedata_sequences'; %'20220218_RatEpithelium';%'20210707_Min6Cells';
power_array_ref = struct('lam755', 2:2:10, 'lam860', 2:2:8,...
                                            'lam720', 2:2:8);
power_array = struct('lam755', [9.64, 20, 30, 40, 50], 'lam860', [16, 32,...
                    48, 64], 'lam720', [12 24 36 48]);
downsample_factor = 2;
coregistration_detector = 'APD1';
nadh_lambda = '755';
cd(project_path)
mkdir(exp_name)
exp_dir = [project_path, '\', exp_name];
cd(exp_dir)
data_type = 'int';
[file_identifiers, roi_names] = determine_unique_file_identifiers(data_type);
roi_names = roi_names(end);
file_identifiers = file_identifiers((end - 1):end);
[file_name_array, calibrated_image_array, calibrated_frame_array] = generate_arrays(...
                            file_identifiers, power_array, power_array_ref);
[calibrated_image_array_downsampled, ~] =...
                            generate_downsampled_arrays(file_identifiers,...
                            calibrated_image_array,...
                            calibrated_frame_array, downsample_factor);
experiment_parameters = save_parameters(exp_name, file_identifiers, data_type);
% clear calibrated_image_array calibrated_frame_array
[calibrated_image_array_downsampled_coregistered,lateral_shift, depth_shift] =...
                    coregister_wavelengths(roi_names, file_identifiers,...
                    calibrated_image_array_downsampled, nadh_lambda,...
                    coregistration_detector);
%%
load LLIFt3; % loads LLIF, DecayMatrix, filledmask
ch755=calibrated_image_array_downsampled(file_identifiers{1});
nadh=ch755(:,:,1,2);
ch860=calibrated_image_array_downsampled(file_identifiers{2});
fad=ch860(:,:,1,1);
threshold1=0.4;
threshold2=0.7;
finalmask=celegans_mask(filledmask,DecayMatrix,lif,nadh,threshold1,threshold2);


mask_info_container = containers.Map;
mask_info_container('NADH') = {{'CHANNEL', '755', 'APD2'},...
                                {'GAUSSIAN', '25', '256'},...
                                {'GAUSSIAN', '20', '120'},...
                                {'BUTTERWORTH', '10', '120', '3'},...
                                {'OTSU', '2', '1'}};
mask_info_container('LLIF') = {{'THRESHOLD_LLIF','0.4','0.7'}};
mask_info_container('SHG') = {{'CHANNEL', '860', 'NDD2'},...
                                {'OTSU', '2', '1'}};
mask_container = generate_masks_celegans(roi_names, file_identifiers,...
                    calibrated_image_array_downsampled_coregistered,...
                    mask_info_container,filledmask,DecayMatrix,lif);
