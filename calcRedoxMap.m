function [rr_map, mean_rr, med_rr, IQR_rr, std_rr, CoV_rr] = calcRedoxMap(NADH, FAD, mask, calc_method)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file: calcBoundFractio.m
% ***Description***:
% This function serves to calculate the fraction of a fluorophore that is
% bound protein in a given FLIM image.

% Written By: Chris and Yang
% Date Written: 10/15/2021
% Modifying Author:
% Date Modified:
% Latest Revision: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function details
% Inputs:
%   NADH = NADH image/image stack
%   FAD = FAD image/image stack
%   mask = previous created mask for redox analysis
%   calc_method = whether we want to calcuate redox "PIXELWISE" or for the
%   "FULLFIELD"
%  Outputs:
%   rr_map = redox ratio map/stack
%   mean_rr = array of mean rr values
%   med_rr = array of median rr values
%   IQR_rr = array of IQR values from rr images
%   std_rr = array of std. deviation values from rr images
%   CoV_rr = array of covariance values from rr images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Calculate redox ratio map
 
rr_map = FAD ./ (FAD + NADH);
rr_map(isnan(rr_map)) = 0;
rr_map(isinf(rr_map)) = 0;
rr_map_masked = rr_map .* mask;
nadh_masked = NADH .* mask;
fad_masked = FAD.*mask;

%% Extract metrics
num_depths = size(rr_map_masked, 3);
mean_rr = zeros(1, num_depths);
med_rr = zeros(1, num_depths);
IQR_rr = zeros(1, num_depths);
std_rr = zeros(1, num_depths);
CoV_rr = zeros(1, num_depths);
if calc_method == 'PIXELWISE'
    for i = 1:num_depths
        rr_image = rr_map_masked(:, :, i);
        mean_rr(i) = mean(nonzeros(rr_image));
        med_rr(i) = median(nonzeros(rr_image));
        IQR_rr(i) = iqr(nonzeros(rr_image));
        std_rr(i) = std(nonzeros(rr_image));
        CoV_rr(i) = std_rr(i)/mean_rr(i);
    end
elseif calc_method == 'FULLFIELD'
    for i = 1:num_depths
        nadh_image = nadh_masked(:, :, i);
        fad_image = fad_masked(:, :, i);
        mean_rr(1, i) = sum(fad_image(:))/(sum(fad_image(:))+sum(nadh_image(:))); 
    end
end
end
