function [FinalShift] = CoRegister3Dim_V1(Fixed,Moveable,WindowSize,Masks)
% Image registration using Matlab's native normxcorr2 function in the Image
% Processing Toolbox.
% Each frame in Moveable is shifted to match with corresponding frame in Fixed.
% Fixed and Moveable should have the same stack height, but can have 
% arbitrary image sizes, even rectangular. Moveable can be smaller than Fixed.
% Array of row and column shifts for each frame is optionally returned as
% Shift. Peak correlation coefficients for each frame are returned as Q.
% 
% Requires: normxcorr2.m(Image processing toolbox), max2
%
% To do: crop FFT to nearest power of 2, but apply translation to full
% image. CAlonzo 12 Mar 2014
% Modified by Yang 06/03/2022, coregister for z-xy, small window, apply
% mask
% to incorporate masks if available, and small windows to do
% co-registrations
% WindowSize: if need to apply small windows, define how many percentage of the columns
% need to use. if 0.1, then 102x102 pixels
% Masks: if there is a need to apply mask, put mask input
imageHeight = size(Fixed,1);
imageWidth = size(Fixed,2);
stackSize = size(Fixed,3);

if WindowSize==1 % do not apply smaller windows for co-registration
    WindowSize1 = imageHeight;
    WindowSize2 = imageWidth;

else
    WindowSize1 =floor(imageHeight*WindowSize);
    WindowSize2 =floor(imageWidth*WindowSize);
end
if Masks ==0
   Masks = zeros(size(Fixed));
else
   Fixed = Fixed.*Masks;
   Moveable = Moveable.*Masks;
end
%% Determine stack size and image size
Shift = zeros(stackSize,2);
Q = zeros(stackSize,1);

%% Registration check for Z, slice-by-slice, see the correlations values with each slice 
rect  = randomWindow2d([imageHeight,imageWidth],[WindowSize1,WindowSize2]);% here to randomly select a fixed sized window if need small regions for Registration check for Z
X_range = [rect.XLimits(1):rect.XLimits(2)];
Y_range = [rect.YLimits(1):rect.YLimits(2)];

corregi_755to860 = zeros(length(3:min(stackSize-2,5)),4); % generate an array to save the layer corespondance e.g., 1(755ex) to 3(860ex) are corresgistered
init_comp = 1;
for fix_755 = 3:min(stackSize-2,5) % start from 3rd, avoid the possibility that it coregistered with previous optical sections in another stack.
    
    for Mov_860 = 1:stackSize
        % Use normxcorr2 to find appropriate shift
        [Q(Mov_860) Shift(Mov_860,:)] = max2(normxcorr2(Moveable(X_range,Y_range,Mov_860),Fixed(X_range,Y_range,fix_755)));%Fixed=EX755EM525;Moveable=EX860EM525;
        Shift(Mov_860,1) = Shift(Mov_860,1) - (WindowSize1);
        Shift(Mov_860,2) = Shift(Mov_860,2) - (WindowSize2);
    end
    [~,order_cor] = max(Q);
    corregi_755to860(init_comp,:) = [fix_755-fix_755,order_cor-fix_755,Shift(order_cor,:)];
    init_comp =init_comp+1;
end
mode_para = mode(corregi_755to860,1);
Z_move = mode_para(2);% if positive, then z should be z+1; e.g., 1st NADH channel(fixed) corresponding to the 2nd FAD(movable stack)
xy_move = mode_para(3:4);
FinalShift = [xy_move,Z_move];

return

function [MaxVal,yx] = max2(A)
% max2(A) returns the maximum value in a 2D array.
% (As opposed to max(A) which returns the column-wise maxima.)
%
% [MaxVal,xy] = max2(A) also returns the location of MaxVal as a  
% row vector, yx. yx(1) is the row, yx(2) is the column.
%
% CAlonzo 21May2012

[MaxVal,y] = max(A);
[MaxVal,x] = max(MaxVal);
yx = [y(x),x];

return