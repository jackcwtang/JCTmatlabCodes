%% DebugPhase
FFTlength = 2*4096;
option.command = ' ';
data = ProcessSpectralInterferogram(FFTlength,option);

%% Display average image (XYZ format)

image = (log(squeeze(mean(data.mag,2))));
image_sqrt = sqrt(squeeze(mean(data.mag,2)));
figure(1)
imagesc(image')
%% Subtract background

bg = squeeze(median(repmat(median(data.mag(1:40,:,:),1),size(data.mag,1),1,1),2));
bg_sqrt = squeeze(median(image_sqrt(1:40,:,:)));
fixed_sqrt = image_sqrt - bg_sqrt;
fixed = image - bg;
figure(5); imagesc(fixed_sqrt')
figure(6); imagesc(fixed')
%% Magnitude variance

mag_var = log(squeeze(var(data.mag,1,2)));
figure(2)
imagesc(mag_var');
title('Magnitude variance')
%% Phase variance

phase_var = squeeze(var(data.phase,1,2));
figure(3)
imagesc(phase_var');
title('Phase variance')