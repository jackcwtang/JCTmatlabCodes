%Hello OCT world
%Jack Tang
%5/27/2020

%clc;
%clear;
option.command = 'raw';
proc_data = ProcessSpectralInterferogram(4096, option);

%%
figure(1);
imagesc(squeeze(proc_data.mag(:,1,:)));
plot(detrend(squeeze(proc_data.mag(1,1,:))-2^15));
    %subtract DC component using 'detrend' and remove dimensions of length 1 using 'squeeze'
    
%%   
RenderOrthoSlice(proc_data,'Jet','log');
%SetImageThreshold(proc_data.mag);