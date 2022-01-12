%% StabilizeVolume.m
%% Load data
clc
clear
data = ProcessSpectralInterferogram(1280*2)
%% Plot the time-averaged data
time_avg = mean(data.mag,2);
figure(1)
imagesc(transpose(log(squeeze(time_avg(:,:,:)))));
title('Time-averaged B-scan');
xlabel('X, pixels');
ylabel('Z, pixels');

%% Crop magnitude for removing fixed pattern noise
raw_mag = log10(permute(data.mag, [3 1 2])); %Now data is in (y,x,time)
mag_crop = raw_mag(300:800,:,:);

figure(2)
imagesc(squeeze(mean(mag_crop,3)))
[threshold, mask] = SetImageThreshold(squeeze(mean(mag_crop,3)));
%% Fix images
mask = mag_crop>threshold;
figure()
imagesc(mask(:,:,5));
mag_cm = mag_crop.*mask;
%%
ref = mag_cm(:,:,1);
fixed = zeros(2*size(raw_mag,1),2*size(raw_mag,2),size(raw_mag,3));
offsets = zeros(size(mag_cm,3),2);
init = fixed;
z_start = floor(size(raw_mag,1)/2);
x_start = floor(size(raw_mag,2)/2);
init(z_start:(z_start+size(raw_mag,1)-1),x_start:(x_start+size(raw_mag,2)-1),:)= raw_mag(:,:,:);

for i = 1:size(mag_cm,3) % calculate translation offsets and apply
    img = mag_cm(:,:,i);
    c = normxcorr2(ref,img);
    [zpeak,xpeak] = find(c==max(c(:)));
    offsets(i,1) = zpeak-size(mag_cm,1);
    offsets(i,2) = xpeak-size(mag_cm,2);
    z_start = floor(size(raw_mag,1)/2)-offsets(i,1);
    x_start = floor(size(raw_mag,2)/2)-offsets(i,2);
    fixed(z_start:(z_start+size(raw_mag,1)-1),x_start:(x_start+size(raw_mag,2)-1),i)= raw_mag(:,:,i);
end
%% Display initial average
init_avg = mean(init,3);
figure(4)
imagesc(init_avg);
title('Initial B-scan average')
xlabel('X, pixels')
ylabel('Z, pixels')
caxis([2.5 5.25])

%% Display fixed average
fixed_avg = mean(fixed,3);
figure(5)
imagesc(fixed_avg);
title('Fixed B-scan average')
xlabel('X, pixels')
ylabel('Z, pixels')
caxis([2.5 5.25])

%% Crop stacks before writing to file
z_start = floor(size(raw_mag,1)/2);
x_start = floor(size(raw_mag,2)/2);
fixed_crop = exp(fixed(z_start+1:(z_start+size(raw_mag,1)),x_start+2:(x_start+size(raw_mag,2)),:));
init_crop = exp(init(z_start+1:(z_start+size(raw_mag,1)),x_start+2:(x_start+size(raw_mag,2)),:));
% fixed_mask = fixed_crop>threshold;
% init_mask = init_crop>threshold;
% fixed_crop_masked = fixed_mask.*fixed_crop;
% init_crop_masked = init_mask.*init_crop;
%% WriteMultiPageTif
WriteMultiPageTif('fixed.tiff', fixed_crop, 8)
WriteMultiPageTif('init.tiff', init_crop, 8)
% %% saveastiff
% options.compress = 'lzw';
% saveastiff(fixed,'fixed_cp.tiff',options);
% saveastiff(mag,'fixed_cp_nofix.tiff',options);