% This function takes as input the file path, scan parameters, and raw data from
% the Insight laser system and returns the interferometric phase (phase) and amplitude (mag). 
% pname is directory path for raw data, DVV.npy, and dispersion. Assumes 
% disperion file names is dispersionLast.txt. protofname is a prototype 
% file name for all of the raw data files. An * denotes where the frame/step
% number should be inserted.  If protofname is a cell array if using (e.g. uigetfile 
% multiselect), to select multiple file names. num_alines is the number of a_lines. If
% option is set to 'raw', the rawdata is written to mag and the dipsersion
% correction to phase. FFTlength is the length of the fft used in
% processing the raw data, i.e. controls the zero padding. If option is set
% to 'bkg' and a background file exists, it will be subtracted.
%
% Author: Brian Applegate
% last modified: 3/7/2020
%pname=basepname;, protofname=fname; frames=length(fname);
function [ mag, phase ] = OCTproc( pname, protofname, frames, num_alines, scantype, option, FFTlength)
% read in OCT raw data (numPy format), dvv file, perform 1st FFT  
    %% read in DVV file, DVV file contains indices of good points
    fdvv = fullfile(pname, '/DVV.npy');
    
    if exist(fdvv, 'file')
        dvv = readNPY(fdvv);
    else 
        fdvv=fullfile(pname,'/raw/DVV.npy');
        if exist(fdvv, 'file')
            dvv = readNPY(fdvv);
        else
        disp('DVV file does not exist!');
        end
    end

    %% read dispersion file
    fdisp = fullfile(pname, 'raw/dispersionLast.txt');
    if exist(fdisp, 'file') == 2 
        dispersion = single(dlmread(fdisp, ','));
        dispPhase = dispersion(2,:);
        dispMag = dispersion(1,:);
        if length(dvv) == length(dispMag)
            if strcmp(option.command,'KaiserAvg')
                dispMag = ones(1,length(dvv)); %once we have dispersion mag fixed to be flat, need to change this
                N = length(dvv);
                Nwin = option.Nwin; %number of windows
                beta = linspace(option.beta(1),option.beta(2),Nwin);
                tmp_dispMatrix = zeros(N,Nwin);
                %Build array of window functions
                for i = 1:length(beta)
                    tmpwin = kaiser(N,beta(i))';
                    win=tmpwin./sum(tmpwin)*2.*dispMag;
                    tmp_dispMatrix(:,i) = win.*exp(-1j*dispPhase);
                end
               dispMatrix = repmat(tmp_dispMatrix,1,1,num_alines);
               dispMatrix = permute(dispMatrix,[3 1 2]);
            else
                dispMatrix=repmat(dispMag.*exp(-1j*dispPhase),num_alines,1);
            end
        else
            dispersion= 'Dispersion file data wrong dimension';
            disp('Dispersion file data wrong dimension, skipping dispersion compensation');
        end
    else
        dispersion= 'Dispersion file not found';
        disp('Dispersion file does not exist, skipping dispersion compensation');
    end
   %% read background file
   fback = fullfile(pname, 'raw/BackgroundData.txt');
    if exist(fback, 'file') == 2 
        background = single(dlmread(fback, ','));
        %bkgMatrix = repmat(background,num_alines,1);
        disp('Background file loaded')
    else
        disp('Background file does not exist, background not subtracted')
    end
    
   
   %% read and process raw data
    nFFT = FFTlength; %number of points to used in the FFT
    aline_pts = floor(nFFT/2);

    if strcmp(option.command,'raw')
        mag = zeros(num_alines, length(dvv), frames,'single');
        phase = dispersion;
    else
        mag = zeros(num_alines, aline_pts, frames);
        phase = zeros(num_alines, aline_pts, frames);
    end

    message=sprintf('Loading %d frames',frames); 
    h = waitbar(0,message); %opens waitbar window to show progress
    
    for ii = 1 : frames %loops through file names, reads in data and does an FFT
        if iscell(protofname)
            fname = protofname{ii};
            fname = fullfile([pname '/raw'],fname);
        else
            fname = strrep(protofname,'*',num2str(ii-1));
            fname = fullfile([pname '/raw'],fname);
        end
        waitbar(single(ii)/single(frames),h,message)

        if exist(fname, 'file')
            tmp = single(readNPY(fname));
            if strcmp(scantype,'MScan')||strcmp(scantype,'Volume MScan')||strcmp(scantype,'BMScan')
                tmp = reshape(tmp,length(tmp)./num_alines,num_alines);
                tmp=tmp';
            elseif strcmp(scantype,'BScan')
            else
                %tmp = reshape(tmp,num_alines,length(tmp)./num_alines);
            end
            tmp = tmp(:,dvv+1);%-2^15;
            if strcmp(option.command,'raw')
                mag(:,:,ii) = tmp;
            else
                %tmp = tmp - mean(tmp, 1); %raw data is u16 where DC is set at 2^15, this shifts DC to 0
                tmp = tmp - 2^15; %raw data is u16 where DC is set at 2^15, this shifts DC to 0
                              
                if exist('background') == 1
                    tmp = tmp - background;
                end
                
                %tmp = tmp - median(tmp,1);
                
                if exist('dispMatrix') == 1
                    tmp = tmp .* dispMatrix;
                end

                tmp2 = fft(tmp, nFFT, 2); % 1st fft 
                if strcmp(option.command,'KaiserAvg')
                    [Magmin,Idx] = min(abs(tmp2),[],3);
                    mag(:,:,ii) = Magmin(:,1:aline_pts);
                    tmp3 = angle(tmp2(Idx));
                    phase(:,:,ii) = tmp3(:,1:aline_pts);
                else
                    mag(:,:,ii) = abs(tmp2(:,1:aline_pts));
                    phase(:,:,ii) = angle(tmp2(:,1:aline_pts));
                end       
            end
        else
            disp(sprintf('% s,\n file does not exist!', fname));
            break;
        end
    end
    close(h)
    
    mag = permute(mag,[1 3 2]);
    phase = permute(phase,[1 3 2]);
end


