%%  ProcVolume.m
%   Processes raw volume data for denoising and display. 

option.command = ' '; % Use standard Hann windowing
option.background = 0.99;
data = ProcessSpectralInterferogram(4096,option);
%%  Show center B-scan
y_mid = ceil(size(data.mag,2)/2);
bscan_mid = squeeze(data.mag(:,y_mid,:))';
figure(1)
imagesc(log10(bscan_mid));
colormap(jet)
caxis([3 6])


%%  Remove fixed pattern noise using X-median subtraction
x_noi = median(data.mag,1);
mag_denoi = data.mag-x_noi;
mag_denoi(mag_denoi<0)=0;
bscan_denoi = squeeze(mag_denoi(:,y_mid,:))';
figure(2)
imagesc(log10(bscan_denoi));
colormap(jet)
caxis([3 6])

%%  Remove fixed pattern noise using Z-median subtraction
z_noi = median(data.mag,3);
mag_denoiz = mag_denoi-z_noi;
mag_denoiz(mag_denoiz<=0)=1;
bscan_denoiz = squeeze(mag_denoiz(:,y_mid,:))';
figure(3)
imagesc(log10(bscan_denoiz));
colormap(jet)
caxis([3 6])
pbaspect([10 10 2])
%%  Display volume

h = orthosliceViewer(log10(mag_denoiz))
h.ScaleFactors = [4 4 1]
h.DisplayRange = [3 6]
h.Colormap = jet
%volumeViewer(mag_denoi);