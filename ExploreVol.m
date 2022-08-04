%% ExploreVol.m

%% Load raw data
option.command = '';
option.background = 0.99;
data = ProcessSpectralInterferogram(2*2048,option);
disp(data.DataDirectory)
%% Rearrange volume data to ZXY format
mag = permute(data.mag,[3 1 2]);
phase = permute(data.phase,[3 1 2]);

%% Denoise volume
denoised = DenoiseVol(mag);

%% View volume
n = 1.5; %refractive index of sample
Nyquist = 15.0717/n;
x_mmvx = 10/size(denoised,2);
z_mmvx = Nyquist/size(denoised,1);

%%
volumeViewer(denoised)
