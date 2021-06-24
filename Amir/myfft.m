%[y] = myfft(x,fs,zpad)
%zpad==1 for not adding

function [y] = myfft(x,fs,z)
    %z=10;
    
    sz=size(x);    
    if sz(1)==1
        x=x';
    end
    n=length(x);
    %w=hanning(n);
    w  = hann(n);
    dw=w.*x;
    freq=(0:1:(z*n)-1) * (fs/(z*n)); % freq. vector 
    Y=fft(double(dw),n*z)/n; % fft
    pos_i=(1:round((z*n)/2)+1); % take positive half
    
    % output
    y.mag = 4*abs(Y(pos_i));
    y.phi = angle(Y(pos_i));
    y.freq = freq(pos_i);
end
