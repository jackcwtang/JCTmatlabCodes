% ProcessVolumeAverage
% Jack Tang
% Last modified 2021-11-02

clear
clc
%option.command = 'TaylorAvg';
%option.beta = logspace(log10(10),log10(44),10);
%data = ProcessSpectralInterferogram(2*1280); % Load data
data = ProcInterferenceBG(2*1280)
%%
time_avg = squeeze(abs(log10(mean(data.mag,2))))';
figure(1)
imagesc(time_avg);
title('Time-averaged B-scan');
xlabel('X, pixels');
ylabel('Z, pixels');
colormap(jet)

%% Crop data in Z to reduce processing time
z_min = input('Z cropping: input minimum Z value: ');
z_max = input('Z cropping: input maximum Z value: ');

mag_crop = data.mag(:,:,z_min:z_max);
phase_crop = data.phase(:,:,z_min:z_max);

if data.scantype == 'Volume'
    phase_crop = unwrap(phase_crop,2);
else
    phase_crop = unwrap(phase_crop,1);
end

% Display Z-cropped B-scan to check the cropped result
figure(2)
if data.scantype == 'Volume'
    time_avg = squeeze(log(mean(mag_crop,2)))';
else
    time_avg = squeeze(log(mean(mag_crop,1)))';
end
imagesc(time_avg);
colormap(gray)
colorbar

%%

%% Subtract bg
bg = repmat(median(reshape(data.mag,size(data.mag,1)*size(data.mag,2),1280),1),size(data.mag,1),1,size(data.mag,2));
bg = permute(bg, [1 3 2]);
vol = data.mag-bg;

time_avg_bg = squeeze(abs(log10(mean(vol,2))))';
figure(2)
imagesc(time_avg_bg);
title('Time-averaged B-scan - median BG');
xlabel('X, pixels');
ylabel('Z, pixels');
colormap(gray)

%%
kernel = GaussKernel([5 5 15],[2 2 6]);
vol_sm = convn(vol,kernel,'same');
vol_sm(vol_sm<0)=0;
figure(3);orthosliceViewer((vol_sm),'ScaleFactors',[3 3 1]);colormap('jet')

vol_N =vol_sm/max(vol_sm,[],'all')*100+1;

volumeViewer(log10(vol_N),'ScaleFactors',[3 3 1])

% %% Crop data in Z to reduce processing time
% z_min = input('Z cropping: input minimum Z value: ');
% z_max = input('Z cropping: input maximum Z value: ');
% 
% mag_crop = data.mag(:,:,z_min:z_max);
% phase_crop = data.phase(:,:,z_min:z_max);
% 
% if data.scantype == 'Volume'
%     phase_crop = unwrap(phase_crop,2);
% else
%     phase_crop = unwrap(phase_crop,1);
% end
% 
% % Display Z-cropped B-scan to check the cropped result
% figure(2)
% if data.scantype == 'Volume'
%     time_avg = squeeze(log(mean(mag_crop,2)))';
% else
%     time_avg = squeeze(log(mean(mag_crop,1)))';
% end
% imagesc(time_avg);
% colormap(gray)
% colorbar
% 
