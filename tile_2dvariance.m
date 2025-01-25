clear
clc
close all
main_path = 'Y:\Einstein\tile_images_resolution_comparison';
addpath(genpath(main_path))
project = 'peritoneum1';%'TBI';%'TBI\LiveDataMode'; %'RatEpithelium'; %'GrekaCells';
project_path = [main_path, '\', project];
exp_name = '10x';%'mod_files';%'mod_files_livedata_sequences'; %'20220218_RatEpithelium';%'20210707_Min6Cells';
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
file_identifiers = file_identifiers((end));
% file_identifiers = file_identifiers((end - 1):end);
[file_name_array, calibrated_image_array,...
    calibrated_frame_array] = generate_arrays(file_identifiers,...
                                    power_array, power_array_ref);

%%
pix_resol=3;
for count=1:8   
        % Here to acquire the mask for cells and collagen based on the SHG
        % image and NADH image
        % First of all, based on the SHG image, to segment the cells from
        % the collagen, using the Otsu method
keyset=keys(calibrated_frame_array);
a=calibrated_frame_array(char(keyset(1)));
shgimar=mean(a(:,:,1:count,4),3);
bright = 1;%0.97
dark = 0;%0.1
snr_images(count)=calc_SNR(shgimar(:,:),pix_resol,100,350) %15,30
end
%%
for count=1:8   
        % Here to acquire the mask for cells and collagen based on the SHG
        % image and NADH image
        % First of all, based on the SHG image, to segment the cells from
        % the collagen, using the Otsu method
keyset=keys(calibrated_frame_array);
a=calibrated_frame_array(char(keyset(1)));
shgimar=mean(a(:,:,1:count,4),3);
bright = 1;%0.97
dark = 0;%0.1
snr_images(i)=calc_SNR(im_array(:,:,i),pix_resol,15,30);
%         Prettyshg = prettyGray(shgimar,dark,bright); 
%         IntThresholdb = multithresh(shgimar,9);%7 
%         maskcollagen = medfilt2(shgimar > IntThresholdb(1),[3 3]);
%           imshow(maskcollagen);

% mask_info_container = containers.Map;
% mask_info_container('SHG') = {{'CHANNEL', '860', 'NDD2'},...
%                                 {'OTSU', '9', '1'}};
% mask_container = generate_masks_epithelium(roi_names, file_identifiers,...
%                     calibrated_image_array,...
%                                                     mask_info_container);
% keyset=keys(mask_container);
% maskcollagen=imbinarize(imcomplement(mask_container(char(keyset(2)))));
% imshow(maskcollagen);

% Identify dark areas in overlapMask after burning onto grayPerp (lesions
% are dark.

threshint = prctile(shgimar,75,'all');
% threshint = 0.5*1e-3;  % modify 3 0.5
% 'threshint' is the raw background intensity acquired by averaging intensity of several regions identified as background
maskcollagen = medfilt2(shgimar > threshint,[5 5]);
sx=size(maskcollagen,1);sy=size(maskcollagen,2);%b1=300;b2=400;b3=250;b4=500;
% sq_mask=zeros(size(maskcollagen));sq_mask(1+b1:sx-b2,1+b3:sy-b4)=ones;
% maskcollagen=imbinarize(maskcollagen.*sq_mask);
% imshow(imadjust(shgimar.*maskcollagen))
% imshow(maskcollagen);
% for 25x 75[10 10], for 20x 75[10 10], for 10x 80[5 5]
% ovary 10x b1=400;b2=400;b3=480;b4=400; 75 [5 5]
% ovary 20x b1=50;b2=50;b3=340;b4=350;  80 [5 5]
% peritoneum 10x b1=450;b2=450;b3=580;b4=500; 80 [5 5]
% peritoneum 20x b1=200;b2=200;b3=300;b4=270; 75 [10 10]

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
%         variancevalue2 = mean2(Vmatr2d);
        
        
        %display images
uplim = 1;
botlim = 0;
bright = 0.99;%0.99
dark = 0.01;%0.01
varprettyima = prettyImage(Vmatr2d,shgimar,'none',jet(64),uplim,botlim,bright,dark);
% imtool(varprettyima);
% figure;imagesc(Vmatr2d);colormap(jet);caxis([0 1]);axis off;
% figure; imagesc(maskcollagen);colormap(gray);caxis([0 1]);axis off;
% figure; imagesc(shgimar.*maskcollagen);colormap(gray);axis off;
output(count)=variancevalue;
% output2(count)=variancevalue2;
end
% imtool(maskcollagen)
% imtool(imadjust(shgimar.*sq_mask))
% imtool(imadjust(shgimar.*maskcollagen))
% imtool(varprettyima.*sq_mask)
% imhist(Vmatr2d.*sq_mask)