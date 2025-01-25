function sq_mask = square_mask(I, radius)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file: square_mask.m
% ***Description***:
% This function serves to create a binary, square mask to remove edge
% effects from downstream analyses

% Written By: Chris
% Date Written: 10/15/2021
% Modifying Author:
% Date Modified:
% Latest Revision: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function details
% Inputs:
%   I = input image
%   radius = the number of pixels that should be removed from the border.
%  Outputs:
%   sq_mask = binary square mask with the same size as the input image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make mask
image_size = size(I);
border = zeros(image_size);
mask = ones(image_size(1)-2*radius);
if length(image_size) == 2
    border(radius+1:image_size(1)-radius,radius+1:image_size(2)-radius) = mask; 
else
    for i = 1:image_size(3)
        border(radius+1:image_size(1)-radius,radius+1:image_size(2)-radius,i) = mask;
    end
end
sq_mask = border;
end