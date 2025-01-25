clear
clc
code_path = 'Y:\Chris\CodeCentralization';
addpath(genpath(code_path))
im_path = 'Y:\Chris\CodeCentralization\Cervix\20220321_LEEP';
cd(im_path)
load('ROI4_images_masks.mat', 'calibrated_image_array_downsampled')
sheesh = calibrated_image_array_downsampled('int_ROI_4_EX_860');
calibrated_downsampled_image = sheesh(:, :, 1, 2, 20);
calibrated_downsampled_image_n = calibrated_downsampled_image -...
                                    min(calibrated_downsampled_image(:));
calibrated_downsampled_image_n = calibrated_downsampled_image_n ./...
                                    max(calibrated_downsampled_image_n(:));
frame_names = {'int_ROI_4_EX_860_z19_RAW_ch01.tif',...
                    'int_ROI_4_EX_860_z19_RAW_ch05.tif',...
                    'int_ROI_4_EX_860_z19_RAW_ch09.tif',...
                    'int_ROI_4_EX_860_z19_RAW_ch13.tif',...
                    'int_ROI_4_EX_860_z19_RAW_ch17.tif',...
                    'int_ROI_4_EX_860_z19_RAW_ch21.tif',...
                    'int_ROI_4_EX_860_z19_RAW_ch25.tif',...
                    'int_ROI_4_EX_860_z19_RAW_ch29.tif'};
im_size = 1024;
frame_array = zeros(im_size, im_size, length(frame_names));
for i = 1:length(frame_names)
    frame_name = frame_names{i};
    frame = double(imread(frame_name));
    frame_array(:, :, i) = frame;
end
im_average = sum(frame_array, 3);
im_average_512 = downsample_array(im_average, 2);
im_average_512_n = im_average_512 - min(im_average_512(:));
im_average_512_n = im_average_512_n ./ max(im_average_512_n(:));
power_860 = 40;
gain_860 = 10;
im_average_512_c = transferfnSP8(im_average_512, gain_860, power_860);
im_average_512_cn = im_average_512_c - min(im_average_512_c(:));
im_average_512_cn = im_average_512_cn ./ max(im_average_512_cn(:));
% [beta_n, ~] = PSDanalysis(im_average_512_n, 5, 1, 8, 290);