%% co-registration codes
clear
load W14_Red_dS1_um290_Jan_CodeCentralizationTrial
Fixed=EX755EM525;
Moveable=EX860EM525;
% maybe apply co-registrations on the bright features only
% ToThre=EX755EM525+EX860EM525;
% Masked = ToThre>0.1*max(nonzeros(ToThre));

[Shift] = CoRegister3Dim_V1(Fixed,Moveable,0.4,0);% 
% (Fixed,Moveable,WindowSize,Masks), if no masks put as zero. Window size: 0-1, 1 means take all the pixels; 0.4 means take 40%
% Shift is the suggested shift, x,y,z (if z is positive 1, it means the 1st layer of the fixed stack need to pair with the 2nd movable stack layer )

[co_registered860ex] = Shift_3Dim(Shift,EX860EM525,EX860EM460,EX860EM430,EX860EM624);
%%
co_registed = co_registered860ex{1};
figure;
for pri = 1:5
    subplot(1,2,1);imagesc(Fixed([200:700],[100:600],pri));axis image;
    subplot(1,2,2);imagesc(co_registed([200:700],[100:600],pri));axis image;
    title([num2str(pri),',Coregistered']);
end


