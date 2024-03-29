%% ExploreVol.m

%% Load raw data
option.command = '';
option.background = 0.99;
data = ProcessSpectralInterferogram(2*2048,option);
disp(data.DataDirectory)
% Rearrange volume data to ZXY format
mag = permute(data.mag,[3 1 2]);
%phase = permute(data.phase,[3 1 2]);

% Denoise volume
denoised = mag-median(mag,2);
denoised(denoised <= 0) = 1;
%% View volume
n = 1.5; %refractive index of sample
Nyquist = 15.0717/n;
x_mmvx = 10/size(denoised,2);
z_mmvx = Nyquist/size(denoised,1);

%%
volumeViewer(mag)
%%
figure()
h=orthosliceViewer(log10(DP1310))
colormap(jet)
clim([3.8 5.8])
g.ScaleFactors = [10/500 10/500 5.29/2048];
h.ScaleFactors = [10/500 10/500 10.76/2048];
title('1310');
%%
figure(2)
imagesc(log10(avg_ST(:,:,400)))
%clim([3.8 5.8])
colormap(jet)
pbaspect([8 5.3 1])
