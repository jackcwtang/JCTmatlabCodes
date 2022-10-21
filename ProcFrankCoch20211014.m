%% Processing script for Frank's cochlea from 2021 10 14

% Load in the data
data_bg = ProcInterferenceBG(1280*2);

%% Display averaged B-scan

time_avg = squeeze(mean(data_bg.mag(),2))';
figure(1);
imagesc(log10(time_avg));

%% Subtract median

time_avg_median = time_avg-median(time_avg,2);
time_avg_median_N = time_avg_median - min(time_avg_median,[],'all')+1;
figure(2);
imagesc(log10(time_avg_median_N+1));
caxis([4.3 5.5])

%% Subtract median again

time_avg_mm = time_avg_median-median(time_avg_median, 2);
figure(3)
imagesc(log10(time_avg_mm));
caxis([4.3 5.5])