        %Amir April-15-2019
%BMscan TimeDomain
tic
close all;clc;
%clear all
dataDir = '.';
vibDir = [dataDir '/TD'];
expDir = pwd;

sep = expDir(1);%['\'];

% str = pwd ;
% idx = strfind(str,'\') ;
% comp = 'pc';
% sep = ['\'];
% if isempty(idx)
%     idx=strfind(str,'/') ;
%     comp = 'mac';
%     sep = ['/'];
% end

plt.intThresh = 0.1;
plt.nsd = 3; % magnitude noise floor criterion (# SDs above noise floor)
NF = 1;%set 0 to not consider noise floor!


ScanParams = readScanParams;
AudioParams = readAudioParams;
P= readmiscellanousParams;%(Scanparams.fastScanFreq)*1e3
fs = P.fs

params = readAudioParams;
Fr = params.freq
SPL = params.amp;

f = AudioParams.freq; % stimulus frequencies (Hz)
fN = length(f);
L = AudioParams.amp; % stimulus levels (dB SPL)
LN = length(L);
trialN = 1;%params.trialN; % # stimulus repetitions
trialDur = AudioParams.trialDur/1000; % s
vib_fs = ScanParams.fastScanFreq;
trial_ns = round(vib_fs*trialDur);
x_n = ScanParams.x_n;
y_n = ScanParams.y_n;
z_n = ScanParams.z_n;
y_length = ScanParams.y; %mm
f_z=f/1e3;
num=1;
xy_tot = x_n*y_n;

if exist('BMscanvibdata.mat')~=2
    for y_i=1:y_n
        for x_i = 1:x_n
            for L_i = 1:LN
                L_x = L(L_i);
                for f_i = 1:fN
                    f_x = f(f_i);
                    
                    fr_i = LN*fN*x_n*(y_i-1)+(LN*fN*(x_i-1)+(LN*(f_i-1) + L_i)) -1;
                    
                    fname = sprintf('BMscan TD Phase %0.2f kHz %0.1f dB frame %d', f_x/1000,L_x,fr_i); % file name
                    file_name =[vibDir '/' fname];
                    [td_avg_zroi td_trials] = read_tdphase_bmscan(file_name);
                    
                    % loop over Aline points
                    for z_i = 1:z_n
                        vib_z = td_avg_zroi(:, z_i);
                        nsd = 3;
                        %vib(z_i,x_i,y_i,f_i,L_i,:) = vib_z-mean(vib_z);%numZPts, len_steps, width_steps, numFreq, numAmp
                        
                        trial_y=myfft(vib_z,vib_fs*1e3,1);
                        [~,fftidx] = min(abs(trial_y.freq-f_x)); % frequency index
                        trial_mag = trial_y.mag(fftidx);
                        vib_nflo = 200; % (Hz) start noise floor range above/below analysis frequency by this many Hz
                        vib_nfhi = 300; % (Hz) end noise floor range above/below analysis frequency by this many Hz
                        
                        flr1 = find(trial_y.freq > f_x - vib_nfhi & trial_y.freq < f_x - vib_nflo);
                        flr2 = find(trial_y.freq > f_x + vib_nflo & trial_y.freq < f_x + vib_nfhi);
                        nflr = [trial_y.mag(flr1);trial_y.mag(flr2)]; % noise floor range
                        
                        trial_nf(z_i,x_i,y_i,f_i,L_i) = mean(nflr); % trial noise floor mag.
                        trial_nfsd(z_i,x_i,y_i,f_i,L_i) = std(nflr); % trial noise floor SD
                        %trial_snr = 20*log10(trial_mag/trial_nf); % trial snr (dB)
                        %nf(z_i,x_i,y_i,f_i,L_i) = trial_nf + nsd.* trial_nfsd;
                        vib_mag(z_i,x_i,y_i,f_i,L_i) = trial_y.mag(fftidx); % magnitude
                        vib_phi(z_i,x_i,y_i,f_i,L_i) = trial_y.phi(fftidx); % phase (rad)
                        fb = 1e3;% frequency band
                        fs = vib_fs*1e3;
                        %sig_fi(x_i,y_i,z_i,:) = bandpass(vib_z,[f-fb f+fb],fs);
                        %num = num+1;
                        %disp([ '# 'x_i= ',num2str(x_i),'/',num2str(x_n),'  y_i= ',num2str(y_i),'/',num2str(y_n),'  z_i= ',num2str(z_i),'/',num2str(z_n)])
                        
                    end
                end
            end
        end
    end
    %Aline data
    fpath = fullfile(expDir, 'Avg Aline');
    fid = fopen(fpath, 'rb');
    sz_img = fread(fid, 3, 'uint32'); % size of the image
    %fprintf(1, '\nsz_img = %s', mat2str(sz_img)); % image size
    numpts = prod(sz_img);
    aline_tmp = fread(fid, numpts, 'uint16');
    aline_tmp = reshape(aline_tmp, sz_img(end:-1:1)');
    aline_tmp = permute(aline_tmp, [3 2 1]);
    %fprintf(1, 'size(aline_tmp)= %s numL= %d numW= %d', mat2str(size(aline_tmp)), nal.yN, nal.xN)
    avg_aline = squeeze(aline_tmp(y_i,:,:));
    aline = avg_aline;
    save('BMscanvibdata','vib_mag','vib_phi','trial_nf','trial_nfsd','aline')
else
    load('BMscanvibdata')
end
% vibMag = squeeze(vib_mag(:,:,1,end,end));
% NF = squeeze(nf(:,:,1,end,end));
%
% vibMagC = vibMag;
% vibMagC(find(vibMag<NF)) = NaN;
%
% image(vibMagC)
%image(squeeze(vibMagC(:,1,:)))
%plot(squeeze(vibMagC(2,2,:)))

%% Analysis/plotting parameters

plt.resize = 0;
plt.scaleAuto = 1; % auto scale based on min/max in vibration?


% Read in bmscan parameters and data
for y_i = 1:y_n
    for fr_i=1:length(f)
        for spl_i=1:length(L)
            
            %[audioParams, ScanParams, aline, vib] = readBMscanDataFiles('.',fr_i,length(SPL)-spl_i+1);
            %%
            
            vib.mag    = squeeze(vib_mag(:,:,y_i,fr_i,spl_i));
            vib.phi    = squeeze(vib_phi(:,:,y_i,fr_i,spl_i));%rad
            vib.nf_ave = squeeze(trial_nf(:,:,y_i,fr_i,spl_i)) ;
            vib.nf_sd  = squeeze(trial_nfsd(:,:,y_i,fr_i,spl_i)) ;
            
            
            
            %% Plotting
            scrnSz = get(0,'screensize');
            scrnAspect = scrnSz(4)/scrnSz(3);
            h=figure('units','normalized','position',[.2 .2 .5 .5]);
            %movegui(h,'center');
            set(h,'Color','w');
            hAspect = (h.Position(4)*scrnSz(4))/(h.Position(3)*scrnSz(3));
            aximg = 0;
            indFigs = 1; % plot individual figures?
            
            pltN = 1; % number of plots (not including reference image)
            pltW = .3; % plot width (normalized units)
            pltH = pltW/hAspect; % normalized height (make square)
            pltTop = 0.5;
            pltBottom = 0.08;
            pltxMarg = 0.3; % margins separating plots along x-axis
            pltyMarg = 0.1;
            
            %% Color maps
            numC = 80; % # color steps
            gray_cmap = linspace(0, 1, numC)';
            gray_cmap = repmat(gray_cmap, 1, 3); % 3 columns of gray colormap?
            jet_cmap = jet(numC);
            hsv_cmap = hsv(numC);
            
            %% Resizing parameters
            %dz = 8.1e-6; % z-res.
            %dz = 5.9e-6; % z-resolution ??? should be 8.1?
            %distZ = params.zN*dz; % z-distance (depth distance)
            ScanParams.x_n_rsz = ScanParams.x/ScanParams.z_res;
            szNew = [ScanParams.z_n ScanParams.x_n_rsz];
            aspectRatio = szNew(1)/szNew(2);
            if plt.resize == 1
                pltH = pltH*aspectRatio;
            end
            
            %% Display text
%             seps = findstr(expDir, sep);
%             dirnameStr = expDir(seps(end-1)+1:seps(end)-1);
%             dirnameStr = strrep(dirnameStr, '_','\_');
%             expnameStr = expDir(seps(end)+1:end);
%             expnameStr = strrep(expnameStr, '_','\_');
            ax1 = axes('Position',[0 0 1 1],'Visible','off');
            %text(.025, .98, dirnameStr, 'FontName','Arial','FontSize',18,'FontWeight','Bold');
            %text(.025, .94, expnameStr, 'FontName','Arial','FontSize',16);
            text(0+.05, .98, [num2str(SPL(spl_i)),'dB SPL, ',num2str(Fr(fr_i)/1e3),' kHz'], 'FontName','Arial','FontSize',14,'FontWeight','Bold');
            
            %% Aline
            
            alineIntMax = max(max(aline));
            alineIntMin = min(min(aline));
            alineNormHigh = alineIntMax;
            alineNormLow = alineIntMin;
            aline_img = (floor(length(gray_cmap)*(aline - alineNormLow)/(alineNormHigh - alineNormLow)) - 1);
            aline_img8 = uint8(aline_img);
            aline_ax = axes('Position',[.1 pltTop pltW pltH]);
            
            if plt.resize == 1
                [aline_imgPlot,~] = imresize(aline_img8,gray_cmap,szNew,'nearest','Colormap','original');
            else
                aline_imgPlot = aline_img8;
            end
            
            %figure()
            %---------------------------------
            %aline_imgi = image(aline_imgPlot);
            %---------------------------------
            colormap(aline_ax,gray_cmap);
            
            if aximg==1
                axis image;
            end
            
            set(gca,'Visible','off');
            aline_axPos = get(aline_ax,'Position');
            
            % Stimulus response
            
            plt.intMin = plt.intThresh * (alineIntMax - alineIntMin) + alineIntMin; % intensity criterion
            plt.nf = NF*(vib.nf_ave + plt.nsd * vib.nf_sd); % noise
            
            
            % Create mask for mag/phase data
            %size(plt.intMin)
            %size(plt.nf)
            
            plt.cln = find(aline >= plt.intMin & vib.mag > plt.nf);
            
            
            plt.mask = zeros(size(aline));
            plt.mask(plt.cln) = 1;
            
            Temp = vib.mag;
            %Temp(~plt.mask) = 0;
            Temp(Temp<plt.nf) = nan;
            Mag(:,:,y_i,spl_i,fr_i) = Temp;
            Phs(:,:,y_i,spl_i,fr_i)    = vib.phi;
            NF_Mag(:,:,y_i,spl_i,fr_i) = plt.nf;
            
            % Get new max/min vibrations based on unmasked data
            vib.max = max(max(vib.mag)); % maximum vibration
            vib.min = min(min(vib.mag)); % minimum vibration
            plt.maxcln = max(max(vib.mag(plt.cln)));
            plt.mincln = min(min(vib.mag(plt.cln)));
            
            if plt.scaleAuto % if auto-scaling, reset scale min/max
                plt.scaleMax = plt.maxcln;
                plt.scaleMin = plt.mincln;
            end
            
            disp(['Max vib = ' num2str(plt.maxcln)]);
            
            plt.scaled_Mag = (vib.mag - plt.scaleMin) / (plt.scaleMax - plt.scaleMin);
            plt.scaled_Mag_Map = floor(length(jet_cmap)*plt.scaled_Mag) + length(gray_cmap);
            plt.scaled_Mag_Map_Cln = plt.scaled_Mag_Map;
            plt.scaled_Mag_Map_Cln(~plt.mask) = 0;
            
            plt.aline = aline_img;
            plt.aline(plt.cln) = 0;
            plt.mag_img = uint8(plt.aline + plt.scaled_Mag_Map_Cln);
            cmap = [gray_cmap; jet_cmap; hsv_cmap];
            
            % Plot Magnitude
            plt.mag_ax = axes('Position',[0+pltxMarg pltTop pltW pltH]);
            
            if plt.resize == 1
                [plt.mag_imgPlot,~] = imresize(plt.mag_img, cmap, szNew, 'nearest', 'Colormap','original');
            else
                plt.mag_imgPlot = plt.mag_img;
            end
            
            %---------------------------------
            plt.mag_imgS = image(plt.mag_imgPlot);
            %---------------------------------
            set(plt.mag_imgS,'CData',plt.mag_imgPlot);
            colormap(plt.mag_ax,cmap);
            plt.mag_axPos = get(plt.mag_ax,'Position');
            if aximg==1
                axis image;
            end
            set(gca,'Visible','off');
            
            set(gca,'FontSize',12);
            plt.mag_cb = colorbar; %copy colorbar properties
            plt.mag_cb.Limits = [80 160]; %
            %disp(plt.mag_cb.Ticks)
            pause(1)
            %disp(plt.mag_cb.Ticks)
            plt.mag_ticks = str2double(plt.mag_cb.TickLabels);
            
            for tn=1:length(plt.mag_ticks)
                yt=((plt.scaleMin + (plt.scaleMax-plt.scaleMin)*(plt.mag_ticks(tn)/numC - 1)));
                yticklbl{tn} = sprintf('%0.1f', yt);
            end
            plt.mag_cb.TickLabels = yticklbl;
            set(plt.mag_ax,'Position',plt.mag_axPos); % reset position/sizing
            
            % if indFigs == 1
            %     htmp = figure;
            %     ax=gca;
            %     plt.mag_imgS = image(plt.mag_imgPlot);
            %     set(plt.mag_imgS,'CData',plt.mag_imgPlot);
            %     colormap(ax,cmap);
            %     plt.mag_axPos = get(ax,'Position');
            %     axis image;
            %     set(gca,'Visible','off');
            %     set(ax,'Position',plt.mag_axPos); % reset position/sizing
            % end
            
            
            
            %% f0 phase
            % Originally adding pi????
            plt.scaled_Phi = floor(length(hsv_cmap)*(vib.phi + pi)/(2*pi)) + length(gray_cmap) + length(jet_cmap); %to see BM phase zero!!
            
            %figure()
            plt.scaled_Phi_Map = floor(length(hsv_cmap) * (vib.phi + 1*pi)/(2*pi)) + length(gray_cmap) + length(jet_cmap);
            plt.scaled_Phi_Map_Cln = plt.scaled_Phi_Map;
            plt.scaled_Phi_Map_Cln(~plt.mask) = 0;
            plt.phi_img = uint8(plt.aline + plt.scaled_Phi_Map_Cln);
            
            % Plot Phase
            % pltBottom = plt.mag_ax.Position(2) - plt.mag_ax.Position(4) - pltyMarg;
            %
            %
            %plt.phi_ax = axes('Position',[pltW+pltxMarg pltBottom pltW pltH]);
            plt.phi_ax = axes('Position',[0+pltxMarg pltTop-1.1*pltH pltW pltH]);
            
            if plt.resize == 1
                [plt.phi_imgPlot,~] = imresize(plt.phi_img, cmap, szNew, 'nearest', 'Colormap','original');
            else
                plt.phi_imgPlot = plt.phi_img;
            end
            
            %---------------------------------
            plt.phi_imgS = image(plt.phi_imgPlot);
            %---------------------------------
            set(plt.phi_imgS,'CData',plt.phi_imgPlot);
            colormap(plt.phi_ax,cmap);
            plt.phi_axPos = get(plt.phi_ax,'Position');
            if aximg==1
                axis image;
            end
            set(gca,'Visible','off');
            
            %%
            plt.phi_cb = colorbar;
            plt.phi_cb.Limits = [2*numC 3*numC];
            ticks = str2double(plt.phi_cb.TickLabels);
            set(gca,'FontSize',12);
            ytick = linspace(0, numC, 7);
            yticklbl = cell(length(ytick), 1);
            yt = linspace(-180, 180, 7);
            for n=1:length(ytick)
                yticklbl{n} = sprintf('%0.0f', yt(n));
            end
            plt.phi_cb.TickLabels = yticklbl;
            plt.phi_cb.Ticks = linspace(2*numC,3*numC,7);
            set(plt.phi_ax,'Position',plt.phi_axPos); % reset position/sizing
            
            
            %% TD analysis
        end
    end
end

%% Gain
Gain_flag=1;
if LN>1 & Gain_flag==1
    figure
    
    s1=find(SPL==50);%
    s2=find(SPL==80);
    f_i = length(Fr);
    %G=20*log10(Mag(:,:,4,1)-Mag(:,:,1,1)); %dB Gain
    LPa = 2e-5 * 10.^(SPL/20);
    M1=Mag(:,:,y_i,s1,f_i);
    M2=Mag(:,:,y_i,s2,f_i);
    NF1=NF_Mag(:,:,y_i,s1,f_i);
    NF2=NF_Mag(:,:,y_i,s2,f_i);
    G=20*log10(M1/LPa(s1))-20*log10(M2/LPa(s2));
    
    
    
    
    plt.cln = find(aline >= plt.intMin & M1 > NF1 & M2 > NF2);
    plt.mask = zeros(size(aline));
    plt.mask(plt.cln) = 1;
    
    plt.maxcln = max(max(G(plt.cln)));
    plt.mincln = min(min(G(plt.cln)));
    plt.scaleMax = plt.maxcln;
    plt.scaleMin = plt.mincln;
    plt.scaled_Mag = (G - plt.scaleMin) ./ (plt.scaleMax - plt.scaleMin);
    
    plt.scaled_Mag_Map = floor(length(jet_cmap)*plt.scaled_Mag) + length(gray_cmap);
    plt.scaled_Mag_Map_Cln = plt.scaled_Mag_Map;
    plt.scaled_Mag_Map_Cln(~plt.mask) = 0;
    plt.mag_img = uint8(plt.aline + plt.scaled_Mag_Map_Cln);
    plt.mag_ax = axes('Position',[.05 .05 .8 .8]);
    
    plt.mag_imgPlot = plt.mag_img;
    
    %-------------
    plt.mag_imgS = image(plt.mag_imgPlot);
    %-------------
    
    set(plt.mag_imgS,'CData',plt.mag_imgPlot);
    colormap(plt.mag_ax,cmap);
    plt.mag_axPos = get(plt.mag_ax,'Position');
    if aximg==1
        axis image;
    end
    set(gca,'Visible','off');
    
    plt.mag_cb = colorbar;
    plt.mag_cb.Limits = [80 160]; %
    plt.mag_ticks = str2double(plt.mag_cb.TickLabels);
    
    for tn=1:length(plt.mag_ticks)
        yt=((plt.scaleMin + (plt.scaleMax-plt.scaleMin)*(plt.mag_ticks(tn)/numC - 1)));
        yticklbl{tn} = sprintf('%0.1f', yt);
    end
    plt.mag_cb.TickLabels = yticklbl;
    set(plt.mag_ax,'Position',plt.mag_axPos); % reset position/sizing
    
    text(.3,-2, ['dB Gain, ',num2str(Fr(f_i)/1e3),' kHz; ',num2str(SPL(s2)),' to ',num2str(SPL(s1)),' SPLs'], 'FontName','Arial','FontSize',15,'FontWeight','Bold');
    
end

TC=0;
if fN>1 & TC==1
    figure(100)
    x_i = 39;
    z_i =12;
    y_i =1;
    
    spl_i = 1;
    subplot(2,1,1);plot(Fr,squeeze(Mag(z_i,x_i,y_i,spl_i,:)));hold on;ylabel('Disp. (nm)')
    subplot(2,1,2);plot(Fr,unwrap(squeeze(Phs(z_i,x_i,y_i,spl_i,:)))/2/pi);hold on
    xlabel('fr (kHz)');ylabel('phase (cyc)');
end



toc
fclose all

%% Interpolation
%
% xrow = 1:x_n;
% zcol = 1:z_n;
%
% newpoints = 100;
% [xq,yq] = meshgrid(...
%             linspace(1,x_n,newpoints ),...
%             linspace(1,z_n,newpoints ));
% G_int = interp2(xrow,zcol,G,xq,yq,'cubic');
% subplot(1,2,1);image(G);
% subplot(1,2,2);image(G_int)
% %[c,h]=contourf(xq,yq,BDmatrixq);
% %%
% xrow = 1:x_n;
% zcol = 1:z_n;
% newpoints=1000;
% C=G;
% idxgood=~(isnan(C));
%
% %// define a "uniform" grid without holes (same boundaries and sampling than original grid)
% [AI,BI] = meshgrid(xrow,zcol);
%
% %// re-interpolate scattered data (only valid indices) over the "uniform" grid
% CI = griddata( AI(idxgood),BI(idxgood),C(idxgood), AI, BI ) ;
%
% [XI,YI] = meshgrid(linspace(1,x_n,newpoints ),linspace(1,z_n,newpoints )) ;   %// create finer grid
% ZI = interp2( AI,BI,CI,XI,YI ) ; %// re-interpolate
%
% contourf(XI,YI,flipud(ZI),50);
%
%
%
%  f = figure;
%  ax = axes('Parent',f);
%  h = surf(XI,YI,flipud(ZI),'Parent',ax);
%  set(h, 'edgecolor','none');
%  view(ax,[0,90]);
%  colormap(jet);
%  colorbar;