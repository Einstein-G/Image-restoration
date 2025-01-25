function [im]=clonestampzeros(im)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file: clonestampzeros.m
% ***Description***:
% This function serves to "clone stamp" our mask image for beta analysis.
% The signal attributed to mitochondria will be amplified to fill the whole
% image field. This process removes noise from the downstream PSD analysis
% of the image

% Written By: Chris and Yang
% Date Written: 10/15/2021
% Modifying Author:
% Date Modified:
% Latest Revision: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function details
% Inputs:
%   image = input image for which we are clone stamping. This randomly
%   translates the signal around the full image field until all of the 0
%   pixels are removed
%  Outputs:
%   im = clone stamped image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Clone Stamp

[m, n] = size(im);
for i=1:100
    rn=round(rand*2*m-m); % was before (rand*1024-512)
    rn2=round(rand*2*m-m);
    imold=im;
    im2 = circshift(im,[rn rn2]);
    imnew= imold.*(imold>0)+(imold==0).*im2;
    %imagesc(imnew);
    %colormap gray
    im=imnew;
    if sum(sum(im==0))==0
        break
    end
    % pause 
end
%disp(['clone stamped image in ',num2str(i),' iterations'])
