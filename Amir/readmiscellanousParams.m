function [params] = readmiscellanousParams(tmpDir) %% Read ScanParams.txt and ProcOpts.txt
    rootDir = '.';
    if nargin<1
        tmpDir = rootDir;
    end
    params = [];
        
    %% Read in scan parameters  
    fname = fullfile(tmpDir, 'miscellaneous information.txt');
    fid = fopen(fname, 'r');
    scanprms_txt = fread(fid, '*char')';
    fclose(fid);

    [idx, idx2] = regexp(scanprms_txt, 'OCTtrigRate\=');
    len_txt = scanprms_txt(idx2+1:idx2+20);
    len_txt = strtok(len_txt);
    scan_len = str2double(len_txt);
    params.fs = scan_len;  % saved in Hz
    
    [idx, idx2] = regexp(scanprms_txt, 'LaserTotalPoints\=');
    len_txt = scanprms_txt(idx2+1:idx2+20);
    len_txt = strtok(len_txt);
    scan_len = str2double(len_txt);
    params.LaserTotalPoints = scan_len;  % saved in Hz
    
    [idx, idx2] = regexp(scanprms_txt, 'LaserSamplePoints\=');
    len_txt = scanprms_txt(idx2+1:idx2+5);
    len_txt = strtok(len_txt);
    scan_len = str2double(len_txt);
    params.LaserSamplePoints = scan_len ; % saved in Hz

end