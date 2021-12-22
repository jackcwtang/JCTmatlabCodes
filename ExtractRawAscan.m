%% Get raw A-line
option.command = 'raw';
data = ProcessSpectralInterferogram(1280*2,option);

%% 
% figure(1)
% imagesc(
%%
A = fftshift(fft(data.mag(),[],3),3);
B = abs(A)- min(abs(A))+1;
figure(1); orthosliceViewer(log10(B))
