function oimg = miprmdebrisn(img,excSize,hood)
% MIPRMDEBRISN  Removes small binary objects from the image whose dimension
% is smaller than excSize
%
%   OIMG = MIPRMDEBRISN(IMG,EXCSIZE)
%
%   This function removes structures smaller than EXCSIZE 
%   in the binary image IMG. The output OIMG is also a binary image
%
%   Medical Image Processing Toolbox

L = bwlabeln(img,hood); % 8 is the neighborhood size
S = regionprops(L,'Area');
oimg = ismember(L,find([S.Area] >= excSize));
