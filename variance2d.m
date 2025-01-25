clear
clc
close all
main_path = 'Z:\Einstein\codecentralization\acs\sectionedtissue';
addpath(genpath(main_path))
project = 'pancreas2';%'TBI';%'TBI\LiveDataMode'; %'RatEpithelium'; %'GrekaCells';
project_path = [main_path, '\', project];
exp_name = '20x';%'mod_files';%'mod_files_livedata_sequences'; %'20220218_RatEpithelium';%'20210707_Min6Cells';
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
[file_name_array, calibrated_image_array,...
    calibrated_frame_array] = generate_arrays(file_identifiers,...
                                    power_array, power_array_ref);
   
        % Here to acquire the mask for cells and collagen based on the SHG
        % image and NADH image
        % First of all, based on the SHG image, to segment the cells from
        % the collagen, using the Otsu method
keyset=keys(calibrated_frame_array);
a=calibrated_frame_array(char(keyset(1)));
shgimar=mean(a(:,:,:,4),3);
bright = 1;%0.97
dark = 0;%0.1

threshint = prctile(shgimar,75,'all');
maskcollagen = medfilt2(shgimar > threshint,[10 10]);
imshow(maskcollagen);

        % Here to calculate the 2D directional variance based on the SHG
        % image
%         shgimar=Prettyshg;
        sz = size(shgimar,1);
        sz2 = size(shgimar,2);
        armd = 10;
        [aS] = calcfibangspeed(shgimar,armd,1);
        Cwhole = cos(2*aS);
        Swhole = sin(2*aS);
        shgmask2D = maskcollagen;
        Vmatr2d = zeros(sz,sz2);
        
        for ia = (armd+1):(sz-armd)
            for ja = (armd+1):(sz2-armd)
            
                localCw = Cwhole((ia-armd):(ia+armd),(ja-armd):(ja+armd));
                localSw = Swhole((ia-armd):(ia+armd),(ja-armd):(ja+armd));
                maskre = logical(shgmask2D((ia-armd):(ia+armd),(ja-armd):(ja+armd)));
                Cvalue = mean(localCw(maskre));
                Svalue = mean(localSw(maskre));
                Rvalue = sqrt(Cvalue^2+Svalue^2);
                Vvalue = 1-Rvalue;
                Vmatr2d(ia,ja) = Vvalue;
            end
        end
   
        % Here to acquire the other metrics       
        variancevalue = mean(Vmatr2d(maskcollagen));
        
        %display images
uplim = 1;
botlim = 0;
bright = 0.99;%0.99
dark = 0.01;%0.01
varprettyima = prettyImage(Vmatr2d,shgimar,'none',jet(64),uplim,botlim,bright,dark);
imtool(varprettyima);