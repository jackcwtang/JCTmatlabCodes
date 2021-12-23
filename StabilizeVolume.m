%% StabilizeVolume.m
%% Load data
data = ProcessSpectralInterferogram(1280*2)
%% Plot the time-averaged data
time_avg = mean(data.mag,2);
figure(1)
imagesc(transpose(log(squeeze(time_avg))));
title('Time-averaged B-scan');
xlabel('X, pixels');
ylabel('Z, pixels');

%% Crop magnitude/phase
mag_crop = data.mag(:,:,328:end);

%%
idx = 1;
img1 = squeeze(mag_crop(:,idx,:))';
img2 = squeeze(mag_crop(:,idx+1,:))';
figure(2)
imagesc(log10(img2));
title('First Frame');
xlabel('X, pixels');
ylabel('Z, pixels');
    
%%
for idx = 1:2
    img1 = squeeze(mag_crop(:,idx,:));
    img2 = squeeze(mag_crop(:,idx+1,:));
    c = normxcorr2(squeeze(mag_crop(:,i,:)),squeeze(mag_crop(:,i+1,:)));
    
end

%%
function [stabilized] = StabilizeVolume(mag_crop, phase_crop)
    i = 100;
    c = normxcorr2(squeeze(mag_crop(:,i,:)),squeeze(mag_crop(:,i+1,:)));
    [max_c,imax] = max(abs(c(:)));
    [ypeak,xpeak] = ind2sub(size(c),imax(1));
    corr_offset = [ypeak xpeak]
    stabilized = corr_offset;
end