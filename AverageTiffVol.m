%%  AverageTiffVol.m
% 
ReadMultiPageTif
data = double(permute(IntData,[3 1 2]));

clear IntData info
%% Subtract background and median filter
cropdata = data(:,:,:);
bkg = repmat(median(cropdata,1),size(cropdata,1),1,1);
cropdata = cropdata - bkg;
cropdata(cropdata<0) = 0;
cropdata = medfilt3(data,[5 5 5]);
clear bkg
load('handel.mat')
sound(y(1:16000),Fs)
%%  Stabilize volume
regdata = RegStackTform(cropdata);

%% Read in other parameters
ScanParamsfile = fullfile(pname,'ScanParams.txt'); % Scan parameters
fid = fopen(ScanParamsfile);
fgetl(fid);
LengthStr = fgetl(fid);
WidthStr = fgetl(fid);
fclose(fid);

ProcOptsfile = fullfile(pname,'ProcOpts.txt'); %
fid = fopen(ProcOptsfile);
DepthStr = textscan(fid,'%s',1,'delimiter','\n', 'headerlines',5);
fclose(fid);


pat = digitsPattern;

tmp1 = extract(LengthStr,pat);
xdem = str2double([tmp1{1},'.',tmp1{2}]);

tmp1 = extract(WidthStr,pat);
ydem = str2double([tmp1{1},'.',tmp1{2}]);

tmp1 = extract(DepthStr{1},pat);
zdem = str2double([tmp1{1},'.',tmp1{2}]);
du = [ydem xdem zdem]./size(cropdata);
pixelsize = min(du,[],'all');
scale= du/pixelsize; %scale for orthosliceviewer

clear fid pat tmp1 DepthStr LengthStr WidthStr ScanParamsfile ProcSoptsfile du

%%  Average with registered data
avg_bscan = squeeze(mean(regdata,2))';
figure(1)
imagesc((avg_bscan))
colormap(jet)
pbaspect([size(regdata,1),size(regdata,2),1])
title('Registered')

%% Average with non-registered data
avg_noreg = squeeze(mean(cropdata(:,:,551:1050),2))';
figure(2)
imagesc((avg_noreg))
colormap(jet)
pbaspect([8.5 17.6617*.2441/1.333 1]);

%% median bg sub
