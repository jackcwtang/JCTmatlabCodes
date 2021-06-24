%clear

%%  Read in the raw OCT data
option.command = '';
OCT_data = ProcessSpectralInterferogram(4096, option);
disp(OCT_data.DataDirectory);

%%  Inspect OCT time average, crop OCT_data
time_avg = mean(OCT_data.mag,1);
figure(1)
imagesc(transpose(log(squeeze(time_avg))));
title('Time-averaged B-scan');
xlabel('X, pixels');
ylabel('Z, pixels');
z_min = input('Z cropping: input minimum Z value: ');
z_max = input('Z cropping: input maximum Z value: ');
z_range = z_min:z_max;
%%
interval = input('Time Derivative Interval: input interval (seconds): ');

%%  Time Derivative
delta = TimeDerivative(OCT_data, interval);
