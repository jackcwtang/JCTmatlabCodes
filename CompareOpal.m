%% CompareOpal.m

fftpts = 5447; % 5447 for Insight laser, 2048 for Santec
opal_insight = ProcessSpectralInterferogram(2*fftpts);
%disp(data.DataDirectory)
insight_mmpx = 10.7225/4.0315*191;
santec_mmpx = 508;
nyq_santec = 2048/santec_mmpx;
nyq_insight = 5447/insight_mmpx;
%% Display volumes
figure(1)
z_insight = 1:5447;%1191:1398+725+725;
h = orthosliceViewer(log10(opal_insight.mag(:,:,z_insight)))
colormap(jet)
h.ScaleFactors = [10/500 10/500 nyq_insight*(size(z_insight,2)/5547)/size(z_insight,2)];
title('Insight')
%h.DisplayRange = [4 log10(med_insight)];

figure(2)
z_santec = 1:2048;
g = orthosliceViewer(log10(opal_santec.mag(:,:,z_santec)))
colormap(jet)
g.ScaleFactors = [10/500 10/500 nyq_santec*(size(z_santec,2)/2048)/size(z_santec,2)];
title('Santec')

%% Display Bscans
figure(3)
imagesc(log10(squeeze(opal_insight.mag(126:375,250,1:5447)))')
title('Insight')
%% Register en-face for opal target
[optimizer,metric] = imregconfig("multimodal");
optimizer.MaximumIterations = 500;
optimizer.InitialRadius = 2.5e-3;
optimizer

enface_santec = log10(opal_santec.mag((151:350)-11,(151:350)-7,788));
enface_insight = log10(opal_insight.mag(151:350,151:350,1876));
tform = imregtform(enface_santec, enface_insight,'affine',optimizer,metric);

%% Warp Santec to match Insight
santec_reg = imwarp(enface_santec,tform);

figure(4)
imagesc((santec_reg(11:190,11:190))) %11:190,11:190
title('Santec moving')
pbaspect([size(enface_insight, 1) size(enface_insight, 2) 1])
colormap(parula)
clim([2 5.5])

figure(5)
imagesc(enface_insight(11:190,11:190)) %70:125,70:125
title('Insight fixed')
pbaspect([size(enface_insight, 1) size(enface_insight, 2) 1])
colormap(parula)