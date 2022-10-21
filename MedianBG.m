% DenoiseVol.m
% Jack C. Tang
% Input volume data in ZXY format, outputs median-subtracted volume

function [corrected] = MedianBG(data)
    bg = median(data(:,1:100,:),2);
    corrected = data-bg;
    corrected(corrected <= 0) = 0;