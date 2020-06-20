%Digital wavefront correction for OCT using subaperture correlation

%From the paper "Subaperture correlation based digital adaptive optics for
%full field optical coherence tomography" by Abishek Kumar, Wolfgang
%Drexler, and Rainier A. Leitgeb

%Below code by Jack Tang and Brian Applegate
%Begin 5/27/2020
%Last update 6/15/2020

%clc;
%clear;

%% Process the raw data using ProcessSpectralInteferogram()
option.command = '';
proc_data = ProcessSpectralInterferogram(4096, option);

%% Visually inspect the dataset using RenderOrthoSlice().
RenderOrthoSlice(proc_data,'Jet','log');

%% Select an image in the stack (z_slice) to correct.
% In this case, we pick frame 1024 in the center of the stack. It provides 
% good features for correction, including Reissner's membrane.
z_slice = proc_data.mag(:,:,1024);

% The image will be M x M = 750 x 750 px. We zero pad the z_slice to the
% dimensions 2M x 2M.
padded_z_slice = zeros(1500,1500);
padded_z_slice(376:1125, 376:1125) = z_slice;

% Visually inspect the padded_z_slice. 
figure(11)
imagesc(log10(padded_z_slice));

%% Calculate the 2-D discrete Fourier transform of the image.
% This propagates the 2-D signal (intensity) to the Fourier/pupil plane.
k_slice = fft2(padded_z_slice-mean(padded_z_slice,'all'));
% We first subtract the mean to remove the DC component.

figure(12)
imagesc(log10((abs(k_slice))));

%% Window out the N x N pixel data (D_x,y) at the Fourier plane.
% Do this by embedding it into the center of a 2M x 2M array of zeros.
windowed_aperture = zeros(1500,1500);
windowed_aperture(376:1125, 376:1125) = k_slice(376:1125, 376:1125);

figure(13)
imagesc(log10(abs(windowed_aperture)));

%% Divide the windowed_aperture into K x K subapertures
% In the case of 3 x 3 subapertures, we assign the following indices 
% 1 4 7
% 2 5 8
% 3 6 9
K = 3;
dK = 750/3;
subapertures = zeros(1500,1500,K^2);
for i = 1:K
    for j = 1:K
        subapertures(376+((j-1)*dK):376+j*dK,376+((i-1)*dK):376+i*dK,(i-1)*3+j) = windowed_aperture(376+((j-1)*dK):376+(j*dK),376+((i-1)*dK):376+i*dK);
    end
end
figure(14)
imagesc(log10(abs(subapertures(:,:,9))));

%% IFFT2 of subapertures
subimages = ifft2(subapertures);
figure(15)
imagesc(log10(abs(subimages(:,:,1))));

%% Normalize the image intensities



%% Cross-correlate with the reference aperture
ref = K^2/2+0.5;


% Display reference subaperture and subimage
figure(16)
imagesc(log10(abs(subapertures(:,:,ref))));
figure(17)
imagesc(log10(abs(subimages(:,:,ref))));
