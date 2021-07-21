%% AxialNyquist.m
% Jack Tang
% Calculates the axial resolution and Nyquist depth for swept-source OCT

function [output] = AxialNyquist(center_wavelength, bandwidth, samplepoints)
    k_min = 1/(center_wavelength + bandwidth/2);
    k_max = 1/(center_wavelength - bandwidth/2);
    dk = (k_max - k_min)/samplepoints;
    output.axialres = 1/(k_max - k_min);
    output.nyquist = 1/(4*dk);