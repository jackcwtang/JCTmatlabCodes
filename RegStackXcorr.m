% RegStackXcorr.m
% Jack C. Tang
% Input volume magnitude data in ZXY format, outputs stabilized ZXY volume
% Uses normxcorr2 as the stabilization algorithm

function [regstack] = RegStackXcorr(stack)
%     [threshold, mask] = SetImageThreshold(squeeze(mean(vol,3)));
%     vol_masked = vol.*mask;
%     ref = vol_masked(:,:,1);
    ref = stack(:,:,1);
    regstack = zeros(2*size(stack,1),2*size(stack,2),size(stack,3));
    %stabilized_phase = zeros(2*size(vol,1),2*size(vol,2),size(vol,3));
    offset = zeros(size(vol_masked,3),2);
    
    z_start = ceil(size(stack,1)/2)+1;
    x_start = ceil(size(stack,2)/2)+1;
    z_end = z_start + size(stack,1)-1;
    x_end = x_start + size(stack,2)-1;
    
    for i = 1:size(stack,3)
        img = vol_masked(:,:,i);
        c = normxcorr2(ref,img);
        [zpeak,xpeak] = find(c==max(c(:)));
        offset(i,1) = zpeak-size(vol_masked,1);
        offset(i,2) = xpeak-size(vol_masked,2);
        regstack(z_start-offset(i,1):z_end-offset(i,1),x_start-offset(i,2):x_end-offset(i,2),i) = stack(:,:,i);
        %stabilized_phase(z_start-offset(i,1):z_end-offset(i,1),x_start-offset(i,2):x_end-offset(i,2),i) = phase(:,:,i);
    end
    
    regstack = regstack(z_start:z_end,x_start:x_end,:);
    %stabilized_phase = stabilized_phase(z_start:z_end,x_start:x_end,:);
   