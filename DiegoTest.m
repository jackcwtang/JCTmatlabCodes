%% DiegoTest.m
clear
option.command = '';
option.background = 0.99;
data = ProcessSpectralInterferogram(2*2048, option); % Load data

%% Display B-scan

volume = permute(log(data.mag(:,:,:)),[3 1 2]);
figure(1)
imagesc(squeeze(volume(:,:,150)))

%% Median filter

bg = repmat(median(volume,2),1,size(volume,2),1);
fixed = volume-bg;
fixed(fixed<0) = 0;

figure(2)
imagesc(squeeze(fixed(:,:,150)))

%% Write to tiff stack

Write