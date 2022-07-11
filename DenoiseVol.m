option.command = ''; %Hann window
option.background = .99;
data = ProcessSpectralInterferogram(2*1356) %4096 for Insight, 2*1356 for Santec
%%
%WriteMultiPageTif('2022-03-25 raw.tiff', data.mag, 16)

%% Check where tympanic membrane is
mag_avg = squeeze(log(mean(data.mag,2)))';
figure(2)
imagesc(mag_avg)
%caxis([7.8 10])

%% Crop data 
% z_range = 120:700; %MLP1
% y_range = 150:349; % MLP1
z_range = 120:700; %MLP2
y_range = 177:400; %MLP2

crop_vol = (data.mag(:,y_range,z_range));
%RenderOrthoSlice(data,jet,'log')

%% Check first B-scan for background subtraction
mag1 = squeeze(log(data.mag(:,1,z_range)))';
figure(3)
imagesc(mag1)

%% Median subtraction using first B-scan
med1 = median(crop_vol(:,:,:),1);
bg = repmat(med1, [size(crop_vol,1) 1 1]);
%%
vol_fixed = max(crop_vol - bg,0);
figure(101)
imagesc(squeeze(log(vol_fixed(:,200,:)))')

%% Median subtraction using all B-scans
vol_fixed1 = permute(vol_fixed, [2 1 3]);
vol_fixed2 = permute(vol_fixed, [3 1 2]);
vol_fixed2(vol_fixed2 < 0) = 0;
%avg_fixed2 = mean(vol_fixed2(100:1100,:,1:200),3);
figure(102)
imagesc(log(avg_fixed2))
caxis([7.5 11])


%%
%WriteMultiPageTif('2022-04-26 enface.tiff', vol_fixed1, 16)

%%
WriteMultiPageTif('MLP2.tiff',vol_fixed2, 16)

%% volshow sandbox
volumeViewer(vol_fixed2(100:end,:,:));