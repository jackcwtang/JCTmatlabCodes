% AverageVol.m
% Jack C. Tang
%
% Averages sequential b-scans taken in volume mode using 0mm scan width
% Accepts raw data input, outputs denoised and stabilized b-scan average.

%% Load raw data
option.command = '';
option.background = 0.99;
data = ProcessSpectralInterferogram(2*2048,option);
disp(data.DataDirectory)
mag = permute(data.mag,[3 1 2]);
phase = permute(data.phase,[3 1 2]);
%% Display initial average before denoising and stabilizing
init_avg = squeeze(mean(mag,3));
figure(1)
imagesc((init_avg));
cropped_vol = mag(550:1700,:,:);
cropped_phase = phase(550:1700,:,:);
%% Denoise using median filter
denoised = DenoiseVol(cropped_vol);
denoised_avg = squeeze(mean(denoised,3));
figure(2)
imagesc(mean(denoised,3));

%% Stabilize volume
[stabilized,stabilized_phase,mask] = StabilizeVol(denoised,cropped_phase);

%% Average stabilized volume
stabilized_avg = squeeze(mean(stabilized,3));
figure(3)
imagesc((stabilized_avg))

%% Subtract bg from stabilized average
bg = repmat(median(stabilized_avg,2),1,size(stabilized_avg,2));
fixed_bg = stabilized_avg-bg;
fixed_bg(fixed_bg<0)=0;
figure(4)
imagesc(fixed_bg)

%% Angio
complex = stabilized.*exp(1i*stabilized_phase);
mag_var = mask.*squeeze(var(stabilized,0,3));
phase_var = mask.*squeeze(var(stabilized_phase,0,3));
complex_var = mask.*squeeze(var(complex,0,3));
%% Plot angio
figure(5)
t = tiledlayout(1,3, 'TileSpacing','Compact');
nexttile
imagesc(complex_var);
colormap(jet)
title('Complex Variance')
colorbar

nexttile
imagesc(mag_var);
colormap(jet)
title('Magnitude Variance')
colorbar

nexttile
imagesc(phase_var);
colormap(jet)
title('Phase Variance')
colorbar

%% Magnitude variance
figure(6)
imagesc(mag_var)
colormap(jet)
title('Magnitude Variance')
colorbar
caxis([0.75E8 3E8])
