function [Beta , TPEF_cloned ] = PSDanalysis(TPEF_Cl, cloning_times, plottingSwitch, cell_size, fov)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file: PSDAnalysis.m
% ***Description***:
% This function serves to calculate Beta from a two-photon image; It also
% produces a 4D matrix with all of the clone stamped images.

% Written By: Chris and Yang
% Date Written: 10/15/2021
% Modifying Author:
% Date Modified:
% Latest Revision: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Function details
% Inputs:
%   TPEF_Cl = The input image for which we will be calculating beta
%   cloning_times = the # of clone stamp image we will be generating
%   plottingSwitch = whether or not we visualize the plot from which we fit
%       the Power Spectral Density and extract beta
%   step_um = the step size in um between images
%   cell_size = the average size of a cell in um
%   fov = length, in um, of the field of view
%  Outputs:
%   beta = beta value
%   TPEF_cloned = 4D matrix with all of the clone stamped images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% creating 4D matrix and loop to clone each slice of the stack 5 times and save the cloned images and take the average psd
%cloning_times=5;
image_size = size(TPEF_Cl, 1);
TPEF_cloned (size(TPEF_Cl, 1), size(TPEF_Cl, 2), size(TPEF_Cl,3),cloning_times)=0; %preallocating variable
for i=1:cloning_times; % the loop will be repeated 5 times and then the average of the results will be reoported
    count=i;
    
    %% Kyle's algorithm beofre had a mean function, do not use for 3rd stack dimension
    %apply mask to NADH Image and clone it
   TPEF_Cl2=clonestampzeros(TPEF_Cl);
   TPEF_cloned(:,:,:,count)=TPEF_Cl2;

  for k=1:size(TPEF_Cl,3)  
     imoi=(TPEF_Cl2(:,:,k)); 
         
     [psd freq]=calcRadPSD(imoi);
  
     psd_im_finalC(:,:,k,i)=psd; 
  end
end
 
 psd_mean_ImTPEF= mean(psd_im_finalC,4);
% 
clear i;

%% Plotting and fitting mean PSD

for i=1:size(TPEF_Cl,3) 
  count=i; 
  labeln=' NADH im';
  
%   path= ('C:\Users\dpouli01\Desktop\BCC lesion');
%   cd (path);    
 % Joanna's way to calculate PSD with Kyle's code to do it
     pixnum=cell_size/fov*image_size; % microns/FOV*pixNum => 10/238*512 = ~21 x 0.464 corresponds to 10um. To do the same as skin paper where we fitted at 8.5 um as average of all layers, instead of 10 we will use 8.5/238*512. 
     f1num=1/pixnum;
     f1=find(freq>f1num,1,'first');
     mpsd=max(log10(psd_mean_ImTPEF(:,:,i)));
     minpsd=min(log10(psd_mean_ImTPEF(:,:,i)));
     thr=10^(mpsd-0.98*(mpsd-minpsd)); 
     f2=find(psd_mean_ImTPEF(:,:,i)<thr,1,'first');

     psd_mean_ImTPEFc(:,:)=psd_mean_ImTPEF(:,:,i); %added that 11-15-13

     s=polyfit(log10(freq(f1:f2)),log10(psd_mean_ImTPEFc(f1:f2)),1); % changed that to incorporate slice changes , it was psd_mean_ImTPEF(f1:f2) originally
     yfit=10.^(polyval(s,log10(freq(f1:f2))));
     Beta(count)=s(1); % Stores the mitochondrial clustering values for the image stack
     lf=log10(freq(f1));
     hf=log10(freq(f2));
     Rangef=hf-lf ;
    %stat1JX_2cl=[BetaJX  Rangef  -BetaJX*Rangef];
     
    % Plotting switch
   if plottingSwitch ==1;
    figure(i);
    loglog(freq,psd_mean_ImTPEF(:,:,i),'LineWidth',1.5);
    hold on;
    loglog(freq(f1:f2),(psd_mean_ImTPEFc(f1:f2)),'g','LineWidth',1.5);
    loglog(freq(f1:f2),yfit,'r','LineWidth',1.5);
    axis([10^-4 10^0 10^-4 10^2]) ; %fixing the axis so that the final grabbing frame movie has saem axes for all images
    xlabel('freq. (1/pixels)');
    ylabel('PSD'); 
    title([labeln,' Beta = ',num2str(-Beta(i)), ' depth = OS ', num2str(i)]);
     %    set(gcf, 'PaperPositionMode', 'manual');
     %    set(gcf, 'PaperUnits', 'inches');
     %    set(gcf, 'PaperPosition', [2 1 3.8 3]); hold on;
     %  print(['In vivo skin' '_','PSD_JX_',labeln, label2, i],'-dtiff','-r300');
    movie_PSD_JX(i)= getframe(gca(figure(i)));
   else
   end
     clear f1 f2;     
end   
  %close all