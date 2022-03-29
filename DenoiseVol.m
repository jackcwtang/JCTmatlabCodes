option.command = ' '; %Hann window
option.background = .01;
data = ProcessSpectralInterferogram(4096,option) %4096 for Insight, 2*1280 for Santec
%WriteMultiPageTif('2022-03-25 denoised.tiff', data.mag, 16)

%%
mag_avg = squeeze(mean(data.mag, 2))';
figure(1)
imagesc(mag_avg)
caxis([0 10000])


%% 
%RenderOrthoSlice(data,jet,'log')

med = median(data.mag,1);
corrected= abs(data.mag - med);
figure(101)
imagesc(squeeze(mean(log(corrected),2))')