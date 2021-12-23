function [stabilized] = StabilizeVolume(mag_crop, phase_crop)
    i = 100;
    c = normxcorr2(squeeze(mag_crop(:,i,:)),squeeze(mag_crop(:,i+1,:)));
    [max_c,imax] = max(abs(c(:)));
    [ypeak,xpeak] = ind2sub(size(c),imax(1));
    corr_offset = [ypeak xpeak]
    stabilized = corr_offset;
end