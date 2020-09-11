%%  Read in the raw OCT data
option.command = '';
OCT_data = ProcessSpectralInterferogram(4096, option)
%4096 for Insight lasers
%2560 for Santec laser

%% Plot the time-averaged data
time_avg = mean(OCT_data.mag,1);
figure(1)
imagesc(transpose(log(squeeze(time_avg))));
title('Time-averaged B-scan');
xlabel('X, pixels');
ylabel('Z, pixels');