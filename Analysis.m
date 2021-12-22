%% process raw data
option.command = 'TaylorAvg';
option.beta = logspace(log10(10),log10(44),10);
data = ProcessSpectralInterferogram(4096,option);
figure(1);orthosliceViewer(log10(data.mag))
%% operate on vol
bg = repmat(median(reshape(data.mag,90000,2048),1),300,1,300);
bg = permute(bg, [1 3 2]);
vol = data.mag-bg;


kernel = GaussKernel([5 5 15],[2 2 6]);
vol_sm = convn(vol,kernel,'same');
vol_sm(vol_sm<0)=0;
figure(2);orthosliceViewer((vol_sm),'ScaleFactors',[3 3 1]);colormap('jet')

vol_N =vol_sm/max(vol_sm,[],'all')*100+1;

volumeViewer(log10(vol_N),'ScaleFactors',[3 3 1])