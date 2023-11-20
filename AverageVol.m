% AverageVol.m
% Jack C. Tang
%
% Averages sequential b-scans taken in volume mode using 0mm scan width
% Accepts raw data input, outputs denoised and stabilized b-scan average.

%% Load raw data
%option.command = '';
%option.background = 0.99;
data = ProcessSpectralInterferogram(2*4096);
disp(data.DataDirectory)
mag = permute(data.mag,[3 1 2]); % data is now in ZXY format
%phase = permute(data.phase,[3 1 2]);


%% Display initial average before denoising and stabilizing
init_avg = squeeze(mean(mag,3));
denoised_init = DenoiseVol(init_avg);
figure(1)
imagesc((denoised_init));
title('Raw magnitude average')

%%
cropped_vol = log(mag(2000:3000,:,:)); %550:1700 for OR
cropped_phase = phase(2000:3000,:,:); %550:1700 for OR
aspect = permute(data.ImageDimensions, [3 1 2]);
%% Denoise using median filter
denoised = DenoiseVol(cropped_vol);
denoised_avg = squeeze(mean(denoised,3));
figure(2)
imagesc(denoised_avg);
title('Cropped and denoised average')
%% Stabilize volume
[stabilized,stabilized_phase,mask] = StabilizeVol(denoised,cropped_phase);

%% Average stabilized volume
stabilized_avg = squeeze(median(stabilized,3));
figure(3)
imagesc(log10(stabilized_avg))
title('Stabilized average')
caxis([-.75 .5])
%aspect_z = size(stabilized_avg,1)/size(mag,1)*15.0717/1.50;
%pbaspect([10  aspect_z 1]);


%% Subtract bg from stabilized average
bg = repmat(median(stabilized_avg,2),1,size(stabilized_avg,2));
idxX = 150:450;
idxZ = 1:1001;

fixed_bg = stabilized_avg(idxZ,idxX)-bg(idxZ,idxX);
fixed_bg(fixed_bg<0)=0;
figure(4)
imagesc((fixed_bg))
title('Stabilized bg')
xlabel('X, mm')
ylabel('Z, mm')
%% Brian's plotting code
n = 1.0; % refractive index
X = data.ImageDimensions(1)./double(data.ImageDimensionsPixels(1))*size(fixed_bg,2);
Z = data.ImageDimensions(3)./double(data.ImageDimensionsPixels(3))*size(fixed_bg,1)/n;
h=figure(5);imagesc([0, X],[0,Z],(fixed_bg));colormap('jet');
pbaspect([X/Z 1 1])
xlabel('X, mm')
ylabel('Z, mm')

%caxis([-2 .75])

%% Crop x-dimension
x_range_min = input('X min for cropping: '); %175
x_range_max = input('X max for cropping: '); %450
z_range_min = input('Z min for cropping: '); %1000
z_range_max = input('Z max for cropping: '); %1500

%%
fixed_cropped = fixed_bg(z_range_min:z_range_max,x_range_min:x_range_max);
figure(5)
imagesc((fixed_cropped))
xlabel('X, mm','fontweight','bold')
ylabel('Z, mm','fontweight','bold')
aspect_z = 10*(z_range_max-z_range_min)/2048;
aspect_x = 10*(x_range_max-x_range_min)/660;
aspect_y = 1;

%% Change aspect ratio and formatting
n = 1.5;
conversion_x = 10/667; % in mm/pixel
conversion_y = 15.0717/n/2048;
pbaspect([(x_range_max-x_range_min)/660*size(fixed_bg,2)*conversion_x (z_range_max-z_range_min)/2048*size(fixed_bg,1)*conversion_y 1])

xticks([0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10]*66.7)
xticklabels({'1.0' '1.5' '2.0' '2.5' '3.0' '3.5' '4.0' '4.5' '5.0' '5.5' '6.0' '6.5' '7.0' '7.5' '8.0' '8.5' '9.0' '9.5' '10.0'})
yticks([0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 10]*2048/15.0717/n)
yticklabels({'1.0' '1.5' '2.0' '2.5' '3.0' '3.5' '4.0' '4.5' '5.0' '5.5' '6.0' '6.5' '7.0' '7.5' '8.0' '8.5' '9.0' '9.5' '10.0'})
set(gca,'FontSize',18)
%%
addMMx=@(x) sprintf('%.1f',x*conversion_x);
addMMy=@(y) sprintf('%.1f',y*conversion_y);
xticks([1 2 3 4 5 6 7 8 9 10]*100);
xticklabels(cellfun(addMMx,num2cell([1 2 3 4 5 6 7 8 9 10]*100*size(fixed_cropped,2)/667'),'UniformOutput',false));
yticklabels(cellfun(addMMy,num2cell([1 2 3 4 5 6 7 8 9 10]*204.8*size(fixed_cropped,1)/2048'),'UniformOutput',false));

set(gca,'FontSize',18)


%% Angio
complex = stabilized.*exp(1i*stabilized_phase);
mag_var = mask.*squeeze(var(stabilized,0,3));
phase_var = mask.*squeeze(var(stabilized_phase,0,3));
complex_var = mask.*squeeze(var(complex,0,3));
%% Plot angio
figure(5)
t = tiledlayout(2,2, 'TileSpacing','Compact');
nexttile
imagesc(stabilized_avg);
title('Stabilized average')
hold on

nexttile
imagesc(complex_var);
colormap(jet)
title('Complex Variance')
colorbar

nexttile
imagesc(mag_var);
colormap(jet)
title('Magnitude Variance')
colorbar

nexttile
imagesc(phase_var);
colormap(jet)
title('Phase Variance')
colorbar

%% Magnitude variance
figure(6)
imagesc(mag_var)
colormap(jet)
title('Magnitude Variance')
colorbar
caxis([0 .75])
