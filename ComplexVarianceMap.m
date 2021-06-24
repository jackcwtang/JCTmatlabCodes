%%  Complex variance analysis
%   This function maps the complex variance of a series of B-scans, which
%   should help in locating blood vessels.

%   The OCT signal is a complex (real and imaginary components) quantity 
%   that includes the magnitude and phase of the interfered light. The
%   variance of this signal should be high for structures that experience
%   motion, such as blood vessels. 

%   Originated from: Brian E. Applegate and Jack C. Tang
%   Last modified by: Jack C. Tang
%   Last modified on: 2020-07-28

%%  Create dummy DVV file for Santec laser
%SantecDVV(2560);
%4096 for Insight lasers
%2560 for Santec laser
%dvv=readNPY('DVV.npy');
clear

%%  Read in the raw OCT data
option.command = '';
OCT_data = ProcessSpectralInterferogram(1280, option);
disp(OCT_data.DataDirectory);
%4096 for Insight lasers
%2560 for Santec laser
time_avg = mean(OCT_data.mag,1);
figure(1)
imagesc(transpose(log(squeeze(time_avg))));
title('Time-averaged B-scan');
xlabel('X, pixels');
ylabel('Z, pixels');
z_min = input('Z cropping: input minimum Z value: ');
z_max = input('Z cropping: input maximum Z value: ');
z_range = z_min:z_max;

dt = 1/OCT_data.SweepFrequency;
interval = input('Var of diffs: input diff time interval (us)');
interval = interval * 0.000001;
sample_interval = round(interval/dt);

%%  Create threshold mask
thresh = exp(input('Input a threshold value based on the averaged BM scan: '));
mask = mean(OCT_data.mag(:,:,z_range),1) > thresh;
figure(2)
imagesc(transpose((squeeze(mask))));
title('Threshold mask');
xlabel('X, pixels');
ylabel('Z, pixels');

%%  Save mask for manual fixing
imwrite(squeeze(mask),fullfile('mask.tif'),'tiff','Compression','none');

disp(newline);
disp('Code paused:');
disp('Refine the mask, then save it as mask_manual.tif.')
disp('Press any key to proceed.')
pause;

%%  Read manually fixed mask
mask_manual = imread('mask_manual.tif');
mask_manual = im2double(mask_manual);
figure(3)
imagesc((mask_manual'));
title('Manually refined mask');
xlabel('X, pixels');
ylabel('Z, pixels');

%%  Expand mask_manual dimensions to OCT data dimensions
mask_manual_expanded = zeros(size(OCT_data.mag(:,:,z_range)));
for i = 1:size(OCT_data.mag,2)-1
    mask_manual_expanded(:,i,:) = mask_manual(:,:);
end
disp(newline);
disp('mask_manual expanded successfully');
% repmat() and permute() is ~10% slower, but uses less code

% B = repmat(mask_manual,1,1,300);
% B = permute(B,[1,3,2]);

%%   Apply mask to OCT data
masked_mag = OCT_data.mag(:,:,z_range) .* mask_manual_expanded;
masked_phase = OCT_data.phase(:,:,z_range) .* mask_manual_expanded;

figure(4)
imagesc(log(transpose(squeeze(mean(masked_mag,2)))));
title('Masked magnitude');
xlabel('X, pixels');
ylabel('Z, pixels');

disp(newline);
disp('Masked magnitude and phase created successfully');

%%  Compute variances of magnitude, phase, and complex  
masked_complex = OCT_data.mag(:,:,z_range) .* exp(1i .* OCT_data.phase(:,:,z_range)) .* mask_manual_expanded;
complex_variance = var(masked_complex, 0, 2);
mag_variance = var(masked_mag, 0, 2);
phase_variance = var(masked_phase, 0, 2);

disp(newline);
disp('Variances of magnitude, phase, and complex computed successfully');

%% Plot Average signal vs Variance of signal
figure(5)
tiledlayout(2,3)

% Top row, Average signals
nexttile
imagesc(log(squeeze(mean(masked_mag,2)))');
title('Magnitude average', 'FontSize', 18)
nexttile
imagesc(log(transpose(squeeze(mean(abs(masked_phase),2)))));
title('Phase average', 'FontSize', 18)
nexttile
imagesc(log(transpose(squeeze(mean(abs(masked_complex),2)))));
title('Complex average', 'FontSize', 18)

% Bottom row, Variance signals
nexttile
imagesc(log(transpose(squeeze(mag_variance))));
title('Magnitude variance', 'FontSize', 18)
nexttile
imagesc(log(transpose(squeeze(abs(phase_variance)))));
title('Phase variance', 'FontSize', 18)
nexttile
imagesc(log(transpose(squeeze(abs(complex_variance)))));
title('Complex variance', 'FontSize', 18)

% %% Difference signal processing
% dt = 1/OCT_data.SweepFrequency;
% sample_interval = round(interval/dt);
% 
% sample_interval_end = size(OCT_data.mag,2)-sample_interval
% delta_mag = zeros(10000-sample_interval,112,201);
% delta_phase = zeros(10000-sample_interval,112,201);
% for i = sample_interval:sample_interval_end
%     delta_mag(i-sample_interval+1,:,:) = masked_mag(i+sample_interval,:,:) - masked_mag(i,:,:);
%     delta_phase(i-sample_interval+1,:,:) = masked_phase(i+sample_interval,:,:) - masked_phase(i,:,:);
%     
% end
% 
% % Plot Average signal vs Difference (dt) signal 
% figure(7)
% tiledlayout(2,3)
% % Top row, Average signals
% nexttile
% imagesc(log(transpose(squeeze(mean(masked_mag,1)))));
% title('Magnitude average', 'FontSize', 18)
% nexttile
% imagesc(log(transpose(squeeze(mean(abs(masked_phase),1)))));
% title('Phase average', 'FontSize', 18)
% nexttile
% imagesc(log(transpose(squeeze(mean(abs(masked_complex),1)))));
% title('Complex average', 'FontSize', 18)
% 
% % Bottom row, Difference signals
% nexttile
% imagesc(log(transpose(squeeze(mean(abs(delta_mag),1)))));
% title('Magnitude difference', 'FontSize', 18)
% nexttile
% imagesc(log(transpose(squeeze(mean(abs(delta_phase),1)))));
% title('Phase difference', 'FontSize', 18)
% nexttile
% imagesc(log(transpose(squeeze(mean(abs(delta_mag),1)))));
% title('Complex difference', 'FontSize', 18)
% 


