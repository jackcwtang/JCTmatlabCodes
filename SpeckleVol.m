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
%%  Remove background
bg = median(mag(:,1:175,:),2);
magbg = mag - repmat(bg,1,size(mag,1650),1);
%%  Crop the B-scan
%   Display the bg-subtracted B-scan
figure(2)
avgbscan = abs(mean(magbg,3));
imagesc(log10(avgbscan))
title('Avg B-scan')
caxis([0 log10(max(avgbscan,[],'all'))])
%   Set the crop indices and display cropped B-scan
magcrop = magbg(1100:2400,150:660,:);
figure(3)
avgmagcrop = mean(magcrop,3);
imagesc(log10(abs(avgmagcrop)))
title('Cropped B-scan')
caxis([0 log10(max(avgmagcrop,[],'all'))])

%%  Rolling average of phase variances 
%   (6.60x3.30 mm at 660x1650 px)
nVar = 20;
volPV = zeros(size(magcrop,1), size(magcrop,2), size(magcrop,3)/10-1);
volAvg = zeros(size(magcrop,1),size(magcrop,2),size(magcrop,3)/10-1);
f = waitbar(0,'Starting');
step = 5;
nWidth = (size(magcrop,3)-nVar)/step;

[optimizer, metric] = imregconfig('monomodal');
optimizer.MaximumIterations = 500;
for i = 1:nWidth
    start = (i-1)*step+1; %When i=0, start = 
    stop = (i-1)*step+nVar;
    center = i*10;
    magreg = magcrop(:,:,start:stop);
    magreg(:,:,round(nVar/2)) = magcrop(:,:,center);
    for j = 1:nVar
        tform = imregtform(squeeze(magreg(:,:,j)),squeeze(magreg(:,:,nVar/2)),'translation',optimizer,metric);
        magreg(:,:,j) = imwarp(squeeze(magreg(:,:,j)),tform,'OutputView',imref2d(size(squeeze(magreg(:,:,nVar/2)))));
    end
    volPV(:,:,i) = var(magreg,1,3);
    volReg(:,:,i) = mean(magreg,3);
    waitbar(i/nWidth,f,sprintf('Progress: %d %%', floor(i/nWidth*100)));
    pause(0.01);
end
sound(y(1:16000),Fs)
%%  Check the result

figure()
result = squeeze(volPV(:,:,120));
imagesc(log10(result));

%%  VolumeViewer
%permutevolPV = permute(volPV,[2 3 1]);
volumeViewer(volPV)

%%  Write to tiff stack

WriteMultiPageTif('P1_volPV1.tiff',(volPV),8);
%%
sound(y(1:16000),Fs)
