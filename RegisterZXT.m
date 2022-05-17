% Registers the images a 3D array (Z,X,time) using normxcorr2.

function [output] = RegisterZXT(ZXT)
    ref = ZXT(:,:,1);
    output = zeros(size(ZXT,3),2);
    for i = 1:size(ZXT,3)
        img = ZXT(:,:,i);
        c = normxcorr2(ref,img);
        [zpeak,xpeak] = find(c==max(c(:)));
        output(i,1) = zpeak-size(ZXT,1);
        output(i,2) = xpeak-size(ZXT,2);
    end

