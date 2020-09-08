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
% SantecDVV(1280);
% dvv=readNPY('DVV.npy');

%%  Read in the raw OCT data
option.command = '';
OCT_data = ProcessSpectralInterferogram(4096, option);
%4096 for Insight lasers
%2560 for Santec laser
%%  Inspect OCT data
time_avg = mean(OCT_data.mag,1);
figure(1)
imagesc(transpose(log(squeeze(time_avg))));
title('Time-averaged B-scan');
xlabel('X, pixels');
ylabel('Z, pixels');


%%  Create threshold mask
thresh = exp(input('Input a threshold value based on the averaged BM scan: '));
mask = mean(OCT_data.mag,1) > thresh;
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
imagesc(transpose(mask_manual));
title('Manually refined mask');
xlabel('X, pixels');
ylabel('Z, pixels');

%%  Expand mask_manual dimensions to OCT data dimensions
mask_manual_expanded = zeros(size(OCT_data.mag));
for i = 1:size(OCT_data.mag,1)
    mask_manual_expanded(i,:,:) = mask_manual;
end

% repmat() and permute() is ~10% slower, but uses less code

% B = repmat(mask_manual,1,1,300);
% B = permute(B,[1,3,2]);

%%   Apply mask to OCT data
masked_image = OCT_data.mag .* mask_manual_expanded;

figure(4)
imagesc(log(transpose(squeeze(mean(masked_image,1)))));
title('Masked amplitude');
xlabel('X, pixels');
ylabel('Z, pixels');

%%  Compute variance map  
complex_masked = OCT_data.mag .* exp(1i .* OCT_data.phase) .* mask_manual_expanded;;
complex_variance = var(complex_masked, 0, 1);

figure(5)
imagesc(log(transpose(squeeze(complex_variance))));
title('Complex variance');
xlabel('X, pixels');
ylabel('Z, pixels');

% Variance alone doesn't appear to give any contrast for angiography.

%% Check timing issue: Only look every 60 frames
j = 1:20:77;
slow_complex_masked = complex_masked(:,j,:);
slow_complex_variance = var(slow_complex_masked, 0, 2);
figure(6)
imagesc(transpose(log(squeeze(slow_complex_variance))));
title('Complex variance using slow sampling')
xlabel('X, pixels');
ylabel('Z, pixels');

%% Check phase variance map
phase_masked = OCT_data.phase .* mask_manual_expanded;
slow_phase_masked = phase_masked(:,j,:);
figure(7)
imagesc(transpose(log(squeeze(var(slow_phase_masked, 0, 2)))));
title('Phase variance')
xlabel('X, pixels');
ylabel('Z, pixels');

%% Difference 
complex_diff = diff(masked_complex,2,2);
var_complex_diff = var(complex_diff,0,2);
figure(4)
imagesc(transpose(log(squeeze(var_complex_diff))));
title('Variance of complex double difference')

%% Diff and double diff every several samples

j = 1:10:300;
slow_masked_complex = masked_complex(:,j,:);
slow_complex_diff = diff(slow_masked_complex,1,2);
var_slow_diff= var(slow_complex_diff,0,2);
figure(5)
imagesc(transpose(log(squeeze(var_slow_diff))));
title('Variance of slow complex double difference')

%% 

slow_complex_diff = diff(slow_masked_complex,1,2);
