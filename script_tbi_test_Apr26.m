%% here to use Chris' code: script_tbi.m, to test if the powercalibration curve function works or not.
%% TBI

clear
clc
exp_name = 'mod_files';
addpath(genpath('S:\Chris\CodeCentralization'))
main_path = 'S:\Chris\CodeCentralization\TBI';
addpath(genpath(main_path))
cd(main_path)
mkdir(exp_name)
exp_dir = [main_path, '\', exp_name];
cd(exp_dir)
% here to test spectra data
intensity_file_names = load_files('spec');
unique_rois = determine_rois(intensity_file_names);
file_identifiers = determine_roi_lambdas(intensity_file_names,unique_rois);
for loops = 1:size(file_identifiers,2)
    [para_set,names] = Parameters(['spec_',file_identifiers{loops}],exp_dir);
    displays = vertcat(names,para_set)';
end


%here to test intensity data
intensity_file_names = load_files('int');
unique_rois = determine_rois(intensity_file_names);
file_identifiers = determine_roi_lambdas(intensity_file_names,unique_rois);
for loops = 1:size(file_identifiers,2)
    [para_set,names] = Parameters(['int_',file_identifiers{loops}],exp_dir);
    displays = vertcat(names,para_set)';
end
%% TBI live data
clear
clc
addpath(genpath('S:\Chris\CodeCentralization'))
exp_dir = 'S:\Chris\CodeCentralization\TBI\LiveDataMode\mod_files_livedata';
addpath(genpath(exp_dir))
cd(exp_dir)

%here to test intensity data
intensity_file_names = load_files('int');
unique_rois = determine_rois(intensity_file_names);
file_identifiers = determine_roi_lambdas(intensity_file_names,unique_rois);
for loops = 1:size(file_identifiers,2)
    [para_set,names] = Parameters(['int_',file_identifiers{loops}],exp_dir);
    displays = vertcat(names,para_set)';
end

%% cervical

clear
clc
exp_name = '20220321_LEEP';
main_path = 'S:\Chris\CodeCentralization\Cervix';
addpath(genpath(main_path))
cd(main_path)
mkdir(exp_name)
exp_dir = [main_path, '\', exp_name];
cd(exp_dir)

%here to test intensity data
intensity_file_names = load_files('int');
unique_rois = determine_rois(intensity_file_names);
file_identifiers = determine_roi_lambdas(intensity_file_names,unique_rois);
for loops = 1:size(file_identifiers,2)
    [para_set,names] = Parameters(['int_',file_identifiers{loops}],exp_dir);
    displays = vertcat(names,para_set)';
end

%%

%% Greka

clear
clc
main_path = 'S:\Chris\CodeCentralization';
addpath(genpath(main_path))
project = 'GrekaCells';
project_path = [main_path, '\', project];
exp_name = '20210707_Min6Cells';
cd(project_path)
mkdir(exp_name)
exp_dir = [project_path, '\', exp_name];
cd(exp_dir)

%here to test intensity data
intensity_file_names = load_files('tif');
unique_rois = determine_rois(intensity_file_names);
file_identifiers = determine_roi_lambdas(intensity_file_names,unique_rois);
for loops = 1:size(file_identifiers,2)
    [para_set,names] = Parameters(['int_',file_identifiers{loops}],exp_dir);
    displays = vertcat(names,para_set)';
end


%% RatEpithelium

clear
clc
main_path = 'S:\Chris\CodeCentralization';
addpath(genpath(main_path))
project = 'RatEpithelium';
project_path = [main_path, '\', project];
exp_name = '20220218_RatEpithelium';
cd(project_path)
mkdir(exp_name)
exp_dir = [project_path, '\', exp_name];
cd(exp_dir)

%here to test intensity data
intensity_file_names = load_files('int');
unique_rois = determine_rois(intensity_file_names);
file_identifiers = determine_roi_lambdas(intensity_file_names,unique_rois);
for loops = 1:size(file_identifiers,2)
    [para_set,names] = Parameters(['int_',file_identifiers{loops}],exp_dir);
    displays = vertcat(names,para_set)';
    [illu_powerarray] = PowerCalibrationCurve(gradients,PowerGradient,optical_section,powerstart, powerend);
end
