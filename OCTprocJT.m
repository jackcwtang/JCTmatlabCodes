%% OCTprocJT.m
% Jack Tang
% 2022-09-04

function [mag,phase] = OCTproc(pname, protofname, frames, num_alines, scantype, option, FFTlength)
% read in OCT raw data (numPy format), dvv file, perform 1st FFT
    %% read in DVV file, which contains indices of good points
    fdvv = fullfile(pname,'/DVV.npy');
    
    if exist (fdvv, 'file')
        dvv = readNPY(fdvv);
        dvv_flag = 1;
    else
        fdvv = fullfile(pname,'/raw/DVV.npy');
        if exist(fdvv, 'file')
            dvv = readNPY(fdvv);
            dvv_flag = 1;
        else
            dvv_flag = 0;
            disp('DVV file does not exist!');
        end
    end
    
    %% read dispersion file
    fdisp = fullfile(pname,'raw/dispersionLast.txt');