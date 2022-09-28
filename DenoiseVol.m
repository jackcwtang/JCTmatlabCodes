% DenoiseVol.m
% Jack C. Tang
% Input volume data in ZXY format, outputs median-subtracted volume

function [denoised] = DenoiseVol(vol)
    bg = repmat(median(vol(:,1:100,:),2),1,size(vol,2),1);
    denoised = vol-bg;
    denoised(denoised <= 0) = 0;