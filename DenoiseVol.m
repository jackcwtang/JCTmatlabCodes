option.command = ''; %Hann window
option.background = .99;
data = ProcessSpectralInterferogram(2*2048) %4096 for Insight, 2*1280 for Santec
%%
%WriteMultiPageTif('2022-03-25 raw.tiff', data.mag, 16)

%% Check where tympanic membrane is
mag_avg = squeeze(log(mean(data.mag,2)))';
figure(2)
imagesc(mag_avg)
%caxis([7.8 10])

%% Crop data 
z_range = 1:2048;
crop_vol = log(data.mag(:,:,z_range));
%RenderOrthoSlice(data,jet,'log')

%% Check first B-scan for background subtraction
mag1 = squeeze(log(data.mag(:,1,:)))';
figure(3)
imagesc(mag1)

%% Median subtraction using first B-scan
med1 = median(crop_vol(:,:,:),1);
bg = repmat(med1, [size(crop_vol,1) 1 1]);
%%
vol_fixed = max(crop_vol - bg,0);
figure(101)
imagesc(squeeze(vol_fixed(:,250,:))')
vol_fixed1 = permute(vol_fixed, [2 1 3]);
%% Median subtraction using all B-scans
vol_fixed2 = permute(vol_fixed, [3 1 2]);

%%
%WriteMultiPageTif('2022-04-26 enface.tiff', vol_fixed1, 16)

%%
WriteMultiPageTif('2022-04-28 bscans.tiff',vol_fixed2, 16)