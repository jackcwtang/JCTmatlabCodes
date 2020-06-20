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

z_slice = proc_data.mag(:,:,1024); 
%%
figure(11)
imagesc(log10(z_slice));
%%
k_slice = fft2(z_slice-mean(z_slice,'all'));
%subtract mean to remove DC
%%
figure(12)
imagesc(fftshift(abs(k_slice)));
%%
whole_aperture = zeros(1500,1500);
whole_aperture(376:1125, 376:1125) = k_slice;

figure(13)
imagesc(fftshift(abs(whole_aperture)));
%%
