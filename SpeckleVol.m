%%  SpeckleVol.m
%   Takes over-sampled (in width) volume data and computes rolling images
%   of magnitude variance to construct a volume of magnitude variance

%%  Load the dataset
nFFT = 8192;
data = ProcessSpectralInterferogram(nFFT);

load handel.mat %Hallelujah!
sound(y(1:16000),Fs)
%%  Volume data loads in XYZ, so change to ZXY
mag = permute(data.mag, [3 1 2]);
%%  Display raw B-scan
figure(1)
avgbscan = abs(mean(mag,3));
imagesc(log10(avgbscan))
title('Avg B-scan')
%%  Remove background and display the bg-subtracted B-scan
bg = median(mag(:,1:100,:),2);
magbg = mag - repmat(bg,1,size(mag,2),1);
figure(2)
avgbscan = abs(mean(magbg,3));
imagesc(log10(avgbscan))
title('Avg B-scan')
caxis([0 log10(max(avgbscan,[],'all'))])
%%  Crop the B-scan and display
magcrop = magbg(1000:3000,175:660,:);
figure(3)
avgmagcrop = mean(magcrop,3);
imagesc(log10(abs(avgmagcrop)))
title('Cropped B-scan')
caxis([0 log10(max(avgmagcrop,[],'all'))])
%% Register the volume stack
[optimizer, metric] = imregconfig('monomodal');
optimizer.MaximumIterations = 500;
magreg = zeros(size(magcrop));
message = sprintf('Registering %d frames',size(magcrop,3));
h = waitbar(0,message); % opens waitbar to show progress
for j = 2:size(magcrop,3) % loop for registering B-scans
        tform = imregtform(squeeze(magcrop(:,:,j)),squeeze(magcrop(:,:,j-1)),'translation',optimizer,metric);
        magreg(:,:,j) = imwarp(squeeze(magcrop(:,:,j)),tform,'OutputView',imref2d(size(squeeze(magcrop(:,:,j-1)))));
        waitbar(j/size(magcrop,3),h,message); % update waitbar to show progress
end
sound(y(1:16000),Fs) % notify user that image registration is complete
close(h)
%%  Rolling mag variances and averages
%   (6.60x3.30 mm at 660x1650 px)
nVar = 20;
step = 5;
nWidth = (size(magcrop,3)-nVar)/step+1;

volVar = zeros(size(magreg,1), size(magreg,2), nWidth);
volReg = zeros(size(magreg,1),size(magreg,2), nWidth);
message_var = sprintf('Processing %d variance frames',size(magreg,3));
f = waitbar(0,message_var);

for i = 1:nWidth
    start = (i-1)*step+1; %When i=1, start=1; when i=326, start=
    stop = (i-1)*step+nVar; %When i=1, stop=20
    volVar(:,:,i) = var(magreg(:,:,start:stop),1,3);
    volReg(:,:,i) = mean(magreg(:,:,start:stop),3);
    waitbar(i/nWidth,f,message_var);
end
close(f)
%%  Check the result

figure(4)
result = squeeze(mean(volVar(:,:,20),3));
result(result<=0)=1;
imagesc(log10(result));

%%  VolumeViewer
%permutevolPV = permute(volPV,[2 3 1]);
volumeViewer(volVar)

%%  Write to tiff stack

WriteMultiPageTif('volReg.tiff',(volReg),8);
WriteMultiPageTif('volVar.tiff',(volVar),8);
%%
sound(y(1:16000),Fs)
