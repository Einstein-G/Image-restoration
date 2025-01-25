function [illu_powerarray] = PowerCalibrationCurve(gradients,PowerGradient,optical_section,powerstart, powerend)
%% for code centrailzation. 
% input:
% gradients: power percent array; PowerGradient: Power array with measured illumination
% powers; powerstart: the start power percentage for this stack;  powerend:
% the end power percentage for this stack; optical_section: how many
% optical sections does this stack have.
% output:
% illu_powerarray: the illumination power for each optical section for this
% wavelengths

if nargrin< 5 % no power gradient for this stack
    powerend = powerstart;
else
end

Slope_curve = gradients\PowerGradient;% get the slope the calibration curve
illu_powerarray = Slope_curve.*linspace(powerstart,powerend,optical_section);
end
