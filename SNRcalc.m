%SNR calculation
%Brian Applegate

%Calculates the mean, median, and max SNR using single-point MScan data

%Position a mirror in front of the OCT beam to generate the signal.
%An ND filter will be required to avoid saturating the detector.  
%Add the total attenuation of the ND filter from both passes to the 
%calculated SNR to get the true SNR.

data = ProcessSpectralInterferogram(1280*2);
%%
Mag = squeeze(data.mag);
figure(1); plot(Mag');
idx_peak = 391;
s_mean = mean(Mag(:,idx_peak))
s_median = median(Mag(:,idx_peak))
s_max = max(Mag(:,idx_peak))
s_min = min(Mag(:,idx_peak))
 
noi = std(Mag(:,150:250),0,'all')
 
SNR_mean = 20*log10(s_mean/noi)
SNR_median = 20*log10(s_median/noi)
SNR_max = 20*log10(s_max/noi)
SNR_min = 20*log10(s_min/noi)
SNR = 20*log10(Mag(:,idx_peak)/noi);
SNR_std = std(SNR,0,'all')