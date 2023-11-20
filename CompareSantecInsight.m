%CompareSantecInsight.m

%% Load data set
fftpts = 2048; %2048 for ST, 5447 for insight

data = ProcessSpectralInterferogram(2*fftpts);
disp(data.DataDirectory)
ST22 = data.mag;


clear data
insight_mmpx = 10.7225/4.0315*191;
santec_mmpx = 508;
nyq_santec = 2048/santec_mmpx;
nyq_insight = 5447/insight_mmpx;

%% Santec noise region
%ROI_noi_ST
%ROI_noi_ST = ST_avg22(100:350,422:500,340:385); % FOR DATASET3 2023-01-12 DP Oval
ROI_noi_ST = ST_avg8(161:222,1:100,290:338); % FOR DATASET4: 2023-01-23 JSO Stapes
noi_ST = std(ROI_noi_ST,0,'all');
plot_noi_santec = log10(squeeze(mean(ST_noi_roi,2)));
figure(5)
imagesc(plot_noi_santec')
%% Insight noise (for repositioned tbone)
%ROI_noi_IS = IS1(1:125,1:35,915:1800); % FOR DATASET3 2023-01-12 DP Oval
ROI_noi_IS = IS1(1:500,1:100,1342:1351); % FOR DATASET4: 2023-01-23 JSO Stapes
noi_IS = std(ROI_noi_IS,0,'all');
plot_noi_insight = log10(squeeze(mean(ROI_noi_IS,2)));
figure(6)
imagesc(plot_noi_insight')
%clim([3.5 4])


%% Compute max signal for SNR calculation
max_santec = max(ST_avg8(:,:,150:2048),[],[3]);
max_insight = max(IS1(:,:,408:4440),[],[3]);
figure(12)
histogram(max_insight)
title('Max Insight')
figure(13)
histogram(max_santec)
title('Max Santec')

signal_ST = median(max_santec,'all');
signal_IS = median(max_insight,'all');

max_santec = max(max_santec,[],'all');
max_insight = max(max_insight,[],'all');

% Manually select signal
% signal_IS = 6.10418;
% signal_ST = 6.22127;
%signal_IS = 10^6.49453;
%signal_ST = 10^6.50412;
SNR_santec = (signal_ST/noi_ST);
SNR_insight = (signal_IS/noi_IS);
%% Plot images
figure(2)
title('Insight')
%z_insight = 1:5447;
z_insight = 1558:1558+2048; % 1499:1907+1499 for DP repositioned 12/16; 1330:3170 for DP oval; 1558:1558+2048 for JSO stapes 01/23;
h = orthosliceViewer(log10(IS1(:,:,z_insight)))
colormap(jet)
%h.ScaleFactors = [10/500 10/500 nyq_insight*(size(z_insight,2)/5447)/size(z_insight,2)];
h.ScaleFactors = [10/500 10/500 nyq_insight*(size(z_insight,2)/5447)/size(z_insight,2)];
h.DisplayRange = [3.5 6.6];
IS_mmZ = nyq_insight*(size(z_insight,2)/5447);
%% Display Santec volume
figure(3)
z_santec = 1:2048; % 50:1890 for DP oval; 
g = orthosliceViewer(log10(ST_avg15_bg(:,:,z_santec)))
colormap(jet)
g.ScaleFactors = [10/500 10/500 nyq_santec*(size(z_santec,2)/2048)/size(z_santec,2)];
g.DisplayRange = [3.5 6.5];
ST_mmZ = nyq_santec*(size(z_santec,2)/2048);

%% Santec, avg24 WITH background subtraction STBG1
ST_BGsubtract = ST_avg24 - STBG_fix;
ST(ST <= .002) = 10^3.45;
%% Insight, BG subtracted
figure(4)
z_santec = 141:2048;
j = orthosliceViewer(log10(ST_BGsubtract(:,:,z_santec)))
colormap(jet)
j.ScaleFactors = [10/500 10/500 nyq_santec*(size(z_santec,2)/2048)/size(z_santec,2)];
%j.DisplayRange = [3.341809272766113 6.7857666015625]; this is the default
%for uncorrected data
j.DisplayRange = [3.45 6]
ST_mmZ = nyq_santec*(size(z_santec,2)/2048);

%% Santec, background only BG_avg5
figure(5)
title('Santec BG only')
%z_santec = 141:2048;
k = orthosliceViewer(log10(STBG5(:,:,z_santec)))
colormap(jet)
k.ScaleFactors = [10/500 10/500 nyq_santec*(size(z_santec,2)/2048)/size(z_santec,2)];
%j.DisplayRange = [3.8 6];
ST_mmZ = nyq_santec*(size(z_santec,2)/2048);


%% Insight, raw
figure(9)
p = orthosliceViewer(log10(IS1(:,:,z_insight)))
colormap(jet)
p.ScaleFactors = [10/500 10/500 nyq_insight*(size(z_insight,2)/5447)/size(z_insight,2)];
p.DisplayRange = [4 6.5]

%% Diego laryngoscope volume

figure(11)
title('Diego VF')
z_laryngo = 1:2048;
h = orthosliceViewer(log10(DR1(:,:,z_laryngo)));
colormap(jet)
h.ScaleFactors = [10/2000 10/100 12.7*(size(z_laryngo,2)/2048)/size(z_laryngo,2)];
h.DisplayRange = [3.25 5];

%%
% %% Appply registration from opal target
% crop_santec = santec_avg((51:450)-11,(51:450)-7,:);
% crop_insight = insight_avg(51:450,51:450,:);
% figure(4)
% imagesc(crop_santec(:,:,1034))
% title('Santec')
% figure(5)
% imagesc(crop_insight(:,:,1250+1080))
% title('insight')
% %% 
% reg_santec = imwarp(crop_santec,tform);
% regcrop_santec = reg_santec(11:390,11:390,:);
% reg_insight = crop_insight(11:390,11:390,:);
% %% orthoslice viewer for registered volumes
% figure(2)
% title('Insight')
% z_insight = 1275:1275+1927;
% h = orthosliceViewer(log10(crop_insight(:,:,z_insight)))
% colormap(jet)
% h.ScaleFactors = [10/500 10/500 nyq_insight*(size(z_insight,2)/5447)/size(z_insight,2)];
% h.DisplayRange = [4 6];
% 
% figure(3)
% title('Santec')
% z_santec = 121:2048;
% g = orthosliceViewer(log10(crop_santec(:,:,z_santec)))
% colormap(jet)
% g.ScaleFactors = [10/500 10/500 nyq_santec*(size(z_santec,2)/2048)/size(z_santec,2)];
% g.DisplayRange = [3.8 6];
% 
% %% Find depth profiles
% location_santec = log10(santec_avg(:,:,937));
% figure(4)
% imagesc(location_santec)

