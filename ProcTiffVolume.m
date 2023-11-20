%%  ProcTiffVolume.m
%   Processes .TIFF volume data for denoising and display.

ReadMultiPageTif
data = double(permute(IntData,[1 3 2]));

clear IntData info
%  Put whatever data processing you want here
data = data(:,:,:);
bkg = median(data,1);
data = data - bkg;
data(data<0) = 0.1;
data = medfilt3(data,[5 5 5]);

clear bkg
load('handel.mat')
sound(y(1:16000),Fs)

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
du = [ydem xdem zdem]./size(data);
pixelsize = min(du,[],'all');
scale = du/pixelsize; %scale for orthosliceviewer

clear fid pat tmp1 DepthStr LengthStr WidthStr ScanParamsfile ProcSoptsfile pname du

%%  Display
os4 = orthosliceViewer((data));
os4.ScaleFactors = scale;
colormap(jet)

%%
WriteMultiPageTif('fixed_cochlea_santec.tiff',(data),16)