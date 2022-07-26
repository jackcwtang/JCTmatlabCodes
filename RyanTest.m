%% RyanTest.m


%%
option.command = '';
option.background = 0.99;
data = ProcessSpectralInterferogram(2*2048, option); % Load data
%% Display B-scan
image = squeeze(log(data.mag(:,100,:)))';
figure(1)
imagesc(image)

%% Median filter
bg = repmat(median(image,2),1,250);
figure(2)
imagesc(bg)

%% Subtract bg from B-scan

fixed = image-bg;
figure(3)
imagesc(fixed)
caxis([0 3])