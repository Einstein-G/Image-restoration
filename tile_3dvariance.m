%%
clear
clc
close all
main_path = 'Z:\Einstein\codecentralization';
addpath(genpath(main_path))
project = 'acs';%'TBI';%'TBI\LiveDataMode'; %'RatEpithelium'; %'GrekaCells';
project_path = [main_path, '\', project];
exp_name = 'peritoneumaug2022';%'mod_files';%'mod_files_livedata_sequences'; %'20220218_RatEpithelium';%'20210707_Min6Cells';
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

  
        % Here to acquire the mask for cells and collagen based on the SHG
        % image and NADH image
        % First of all, based on the SHG image, to segment the cells from
        % the collagen, using the Otsu method
keyset=keys(calibrated_frame_array);
a=calibrated_frame_array(char(keyset(1)));

%%
for count=size(a,3)
shgstack1=squeeze(mean(a(:,:,1:count,4,:),3));
bright = 1;%0.97
dark = 0;%0.1

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

% threshint = prctile(shgimar,75,'all');
% threshint = 0.5*1e-3;  % modify 3 0.5
% 'threshint' is the raw background intensity acquired by averaging intensity of several regions identified as background
% maskcollagen = medfilt2(shgimar > threshint,[10 10]);
%  imshow(maskcollagen) ;
% for 25x 75[10 10], for 20x 75[10 10], for 10x 80[5 5]
% Here to create the mask selecting fiber regions
sz=size(shgstack1,1);
sz2=size(shgstack1,2);
sz3=size(shgstack1,3);

threshint = 0.1;  % modify 3 0.5
% 'threshint' is the raw background intensity acquired by averaging intensity of several regions identified as background
maska3d = shgstack1 > threshint; % maska3d is a raw binary mask based on the raw background intensity
meanint = mean(shgstack1(maska3d)); % calculate the mean intensity within the raw binary mask
threshinta = 0.3*meanint; % modify 4 0.45 0.7
% 'threshinta' is an inmproved intensity threshold, and the factor '0.45' can be adjusted according to different sample
maska3da = shgstack1 > threshinta; % 'maska3da' is an improved binary mask
finalmaska = maska3d.*maska3da; % 'finalmaska' is the binary mask acquired based on the above two masks
finalmask = zeros(sz,sz2,sz3);
for j = 1:sz3
    Maskf1 = finalmaska(:,:,j); 
    Maskf2 = miprmdebrisn(Maskf1,15,18); % 'miprmdebrisn.m' is a function which is able to remove very tiny structures
    finalmask(:,:,j) = Maskf2;
end
finalmask = logical(finalmask); % 'finalmask' is the final binary mask selecting the fiber-only regions

% Here to calculate the voxel-wise 3D orientation
armdx = 4; % modify 5 4
armdz = 4; % modify 6 2  
filton = 1; % modify 7 1
para = 2.14; % modify 8 2.14
[aSDE,pSDER,bSDER,gSDER] = calcfibang3D(shgstack1,armdx,armdz,filton,para); 

bwhole = sqrt(1./(tan(2*bSDER*pi/180).^2)+1./(tan(2*gSDER*pi/180).^2));
Cwhole = (bwhole./sqrt(1+bwhole.^2)).*cos(2*aSDE*pi/180);
Swhole = (bwhole./sqrt(1+bwhole.^2)).*sin(2*aSDE*pi/180);
Zwhole = zeros(sz,sz2,sz3);
for m = 1:sz
   for n = 1:sz2
     for o = 1:sz3
        if bSDER(m,n,o) <= 90   
            Zwhole(m,n,o) = 1/sqrt(1+bwhole(m,n,o)^2);
        else
            Zwhole(m,n,o) = -1/sqrt(1+bwhole(m,n,o)^2);
        end
     end
   end
end

Cwholemean = zeros(sz,sz2,sz3);
Swholemean = zeros(sz,sz2,sz3);
Zwholemean = zeros(sz,sz2,sz3);
ll = 0;

armdxx = 7; % modify 9 4
armdzz = 7; % modify 10 2

h = waitbar(0,'Please Wait');
ijk = 0;
nijk = (2*armdxx+1)*(2*armdxx+1)*(2*armdzz+1);
tic

for  i = -armdxx:armdxx
    for j = -armdxx:armdxx
        for k = -armdzz:armdzz
            ijk = ijk+1;
            waitbar(ijk/nijk)
            Cim = circshift(Cwhole,[i j k]);
            Sim = circshift(Swhole,[i j k]);
            Zim = circshift(Zwhole,[i j k]);
                        
            Cwholemean = Cwholemean+Cim;
            Swholemean = Swholemean+Sim;
            Zwholemean = Zwholemean+Zim;
            ll = ll+1;
        end
    end
end
    
toc
close(h)
Cwholemean = Cwholemean/ll;
Swholemean = Swholemean/ll;
Zwholemean = Zwholemean/ll;
Rwholemean = sqrt(Cwholemean.^2+Swholemean.^2+Zwholemean.^2);
Vmatr = 1-Rwholemean;
Vmatr(isnan(Vmatr)) = 0;
Vvaluelocal = mean(Vmatr(finalmask));
Cvalue = mean(Cwhole(finalmask));
Svalue = mean(Swhole(finalmask));
Zvalue = mean(Zwhole(finalmask));
Rvalue = sqrt(Cvalue^2+Svalue^2+Zvalue^2);
Vvalueentire = 1-Rvalue;
shgstackre = shgstack1;
shgstackre = shgstackre/max(max(max(shgstackre)));
prettytheta = zeros(sz,sz2,3,sz3);
uplim = 180;
botlim = 0;
bright = 0.99;%0.99
dark = 0.01;%0.01
%%
cd([exp_dir,'\results']);
for mm = 1:sz3
    shgima = shgstackre(:,:,mm);
    thetaima = aSDE(:,:,mm);
    thetaprettyima = prettyImage(thetaima,shgima,'none',jet(64),uplim,botlim,bright,dark);
    prettytheta(:,:,:,mm) = thetaprettyima;
    imwrite(prettytheta(:,:,:,mm),['prettytheta','.tif'],'Compression','none','WriteMode','append');
end
prettyphi = zeros(sz,sz2,3,sz3);
for mm = 1:sz3
    shgima = shgstackre(:,:,mm);
    phiima = pSDER(:,:,mm);
    phiprettyima = prettyImage(phiima,shgima,'none',jet(64),uplim,botlim,bright,dark);
    % Here 'phiima' is the phi orientation map 
    prettyphi(:,:,:,mm) = phiprettyima;
    imwrite(prettyphi(:,:,:,mm),['prettyphi','.tif'],'Compression','none','WriteMode','append');
end
uplim = 1;
botlim = 0;
prettyvar = zeros(sz,sz2,3,sz3);
for mm = 1:sz3
    shgima = shgstackre(:,:,mm);
    varima = Vmatr(:,:,mm);
    varprettyima = prettyImage(varima,shgima,'none',jet(64),uplim,botlim,bright,dark);
    prettyvar(:,:,:,mm) = varprettyima;
    imwrite(prettyvar(:,:,:,mm),['prettyvar','.tif'],'Compression','none','WriteMode','append');
    imwrite(finalmask(:,:,mm),['finalmask','.tif'],'Compression','none','WriteMode','append');
    imwrite(Vmatr(:,:,mm),['variance','.tif'],'Compression','none','WriteMode','append');
end

end