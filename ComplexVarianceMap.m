%%  Complex variance analysis
%   This function maps the complex variance of a series of B-scans, which
%   should help in locating blood vessels.

%   The OCT signal is a complex (real and imaginary components) quantity 
%   that includes the magnitude and phase of the interfered light. The
%   variance of this signal should be high for structures that experience
%   motion, such as blood vessels. 

%   Originated from: Brian E. Applegate and Jack C. Tang
%   Last modified by: Jack C. Tang
%   Last modified on: 2020-07-14

<<<<<<< HEAD
%% Create dummy DVV file for Santec systems.
SantecDVV(1280)
dvv=readNPY('DVV.npy')

%% Input the raw OCT data
option.command = '';
OCT_data = ProcessSpectralInterferogramSantec(4096, option);

%% Combine magnitude and phase to get the complex signal
complex_data = OCT_data.mag.*exp(1i.*OCT_data.phase);

%% Denoise and create a mask for the image
noise_roi.x_start = 1;
noise_roi.x_end = 10;
noise_roi.y_start = 2;
noise_roi.y_end = 99;
[denoised, masks] = TM_segmentation(noise_roi, 'results/');

%% Compute and display the variance map
V = squeeze(var(complex_data,0,2));
image(transpose(log(V)));
=======
option.command = '';
ProcessSpectralInterferogram(4096, option);
>>>>>>> 8de53b929ddb7acb2a7126a5a3039154b4edfa73
