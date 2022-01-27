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
lower_lim = input('Input least pixel value to keep: ');
upper_lim = input('Input greatest pixel value to keep: ');
mag_crop = raw_mag(lower_lim:upper_lim,:,:);

figure(2)
imagesc(squeeze(mean(mag_crop,3)))
[threshold, mask] = SetImageThreshold(squeeze(mean(mag_crop,3)));
%% Threshold the cropped image to highlight only the important features
mask = mag_crop>threshold;
figure()
imagesc(mask(:,:,5));
mag_cm = mag_crop.*mask;
%% 
ref = mag_cm(:,:,1);
fixed = zeros(2*size(raw_mag,1),2*size(raw_mag,2),size(raw_mag,3));
offsets = zeros(size(mag_cm,3),2);
init = fixed;
z_start = ceil(size(raw_mag,1)/2)+1;
x_start = ceil(size(raw_mag,2)/2)+1;
init(z_start:(z_start+size(raw_mag,1)-1),x_start:(x_start+size(raw_mag,2)-1),:)= raw_mag(:,:,:);

for i = 1:size(mag_cm,3) % calculate translation offsets and apply
    
    % Compute the offsets for peak cross correlation
    img = mag_cm(:,:,i);
    c = normxcorr2(ref,img);
    [zpeak,xpeak] = find(c==max(c(:)));
    offsets(i,1) = zpeak-size(mag_cm,1);
    offsets(i,2) = xpeak-size(mag_cm,2);
    
    % Translate the frame by the computed offsets
%     z_start = ceil(size(raw_mag,1)/2);
%     x_start = ceil(size(raw_mag,2)/2);
    z_end = z_start + size(raw_mag,1)-1;
    x_end = x_start + size(raw_mag,2)-1;
    fixed(z_start-offsets(i,1):z_end-offsets(i,1),x_start-offsets(i,2):x_end-offsets(i,2),i)= raw_mag(:,:,i);
    
    % Set new reference every 10 frames
    if rem(i,10)==0
    ref = fixed(z_start+lower_lim:z_start+upper_lim,x_start:x_end,i);
    end
end
%% Display initial and stabilized averages
% Initial average
init_avg = mean(init,3);
figure(4)
imagesc(init_avg);
title('Initial B-scan average')
xlabel('X, pixels')
ylabel('Z, pixels')
caxis([2.5 5.25])

% Stabilized average
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