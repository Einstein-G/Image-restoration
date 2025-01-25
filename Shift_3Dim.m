function [Co_registeredImage] = Shift_3Dim(varargin)
%% shift the image stacks with corresponding pixel numbers
    init =1;
    Co_registeredImage = {};
    for eachStacks = 2:length(varargin)
        Imagestack = varargin{eachStacks};
        imageHeight = size(Imagestack,1);
        imageWidth = size(Imagestack,2);
        stackSize = size(Imagestack,3);
        Shift = varargin{1};
        % shift rows
        temp = zeros(imageHeight,imageWidth,stackSize);
        if Shift(1) >= 0
            temp(1+Shift(1):imageHeight,:,:) = Imagestack(1:imageHeight-Shift(1),:,:);
        else
            temp(1:imageHeight+Shift(1),:,:) = Imagestack(1-Shift(1):imageHeight,:,:);
        end 

        % shift columns
        temp2 = zeros(imageHeight,imageWidth,stackSize);
        if Shift(2) >= 0
            temp2(:,1+Shift(2):imageWidth,:) = temp(:,1:imageWidth-Shift(2),:);
        else
            temp2(:,1:imageWidth+Shift(2),:) = temp(:,1-Shift(2):imageWidth,:);
        end

        % shift Z depth
        if Shift(3) >= 0
            temp3 = temp2(:,:,[1+Shift(3):stackSize]);
        else
            temp3 = temp2;
        end 
        Co_registeredImage(init) = {temp3};
        init =init+1;

    end
end