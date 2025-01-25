function conc = transferfnSP8(I, gain, P)
%Normalizes Intensity vased on gain, power, objective , DP:
%modified older version by Kyle ( he had made some assupmtions for the
%objective too)

%inputs:  8bit intensity, gain (V), power (mW), and
%outputs: normalized intensity based on uM of fluorescein

% %convert offset from the % reported in text file to 8bit intensity
% In SP8 gain is digital and linear
%g= 0.0000000000000000003311384307*gain.^6.24166276187023; %this was
%function for SP2 where gain is not digital

%calculate concentration ( for SP8 gain is digital/linear , so you only need power
%and gain to normalize)
if sum(P)==0 % when using zero power
    conc=(I)./gain;
else
    P_(1, 1, :) = P;
    conc=((I)./(P_.^2))./gain(1);
end
