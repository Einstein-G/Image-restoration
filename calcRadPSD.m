function[psd freq]=calcRadPSD(im2)
%function will calculate radial PSD from an image
%includes mirroring feature to eliminate image edge artifacts
%Kyle Quinn, June 2012

%figure;
clear slope2
%for i=1%:.1:4
  %  im2=imread('SinglePhoton_1.tif');
  %im2=imread('hfk_1-2mil_day8_2_Series007_z013_ch01.tif');
  sz=size(im2,1);
 [x y]=meshgrid(1:sz,1:sz);
xc=-x+(mean(mean(x)));
yc=y-(mean(mean(y)));
[THETA,RHO] = cart2pol(xc,yc);

 % im2 =NDD2_755n;%NDD1_543;% 
   im2=im2/max(max(im2));
     im3 = im2;%(1:256,1:256);
     im4=[im3 fliplr(im3)];
     im5=[im4;flipud(im4)];
%     im2o=im2;
     im2=im5;
    L=size(im2,1);
    %im2 = noiseonf(512, 2);
    %figure;imagesc(im2)
    
    
f=1;
mask=[];
[x y]=meshgrid(1:size(im2,1),1:size(im2,2));
xc=-x+(mean(mean(x)));
yc=y-(mean(mean(y)));
[THETA,RHO] = cart2pol(xc,yc);%determine distance of each pixel from center
ang=reshape(THETA-pi/2,1,[]);
rad=reshape(RHO,1,[]);

ind=find(rad>(max(max(xc))+.5)); %find pixels outside of max radius inside square

ang(ind)=[];

rad(ind)=[];
d=rad;
dr=round(d/f)*f;%round distance to nearest pixel


vals=f:f:(max(max(xc))+.5);%define bin size to make psd
%il=min(min(Im2)):1:255;
il=0:1:(L/2-1);
di=zeros(length(il),length(vals));
ffi=zeros(length(il),length(vals));
ffi2=zeros(length(il),length(vals));

shgfft=fft2(double(im2));
y1 = fftshift(shgfft);
psd1 = y1.*conj(y1)/L/L;
ff=reshape((psd1),1,[]);

%fff=reshape(fff,1,[]);
ff(ind)=[];
%fff(ind)=[];
clear fr psd
for j=1:length(vals)
    ind2=find((dr==vals(j)));
    fr(j)=mean(dr(ind2));
    psd(j)=mean(ff(ind2));
    
   % psd(j)=sum(ff(ind2));
   % fffi(i,j)=mean(fff(ind2));
end

%freq=(1/1024)*(0:511);freq(1)=[];
freq=(1/L)*(0:L/2-1);freq(1)=[];
%freq2=(1/238)*(0:255);freq2(1)=[];
psd(1)=[];