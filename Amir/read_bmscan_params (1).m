function [params] = read_bmscan_params(tmpDir) %% Read ScanParams.txt and ProcOpts.txt
    rootDir = '.';
    if nargin<1
        tmpDir = rootDir;
    end
    params = [];
        
    %% Read in scan parameters  
    fname = fullfile(tmpDir, 'ScanParams.txt');
    fid = fopen(fname, 'r');
    scanprms_txt = fread(fid, '*char')';
    fclose(fid);

    [idx, idx2] = regexp(scanprms_txt, 'length\=');
    len_txt = scanprms_txt(idx2+1:idx2+20);
    len_txt = strtok(len_txt);
    scan_len = str2double(len_txt);
    params.x = scan_len * 10^-3; % saved in mm

    [~, idx2] = regexp(scanprms_txt, 'lengthSteps\=');
    len_txt = scanprms_txt(idx2+1:idx2+20);
    len_txt = strtok(len_txt);
    len_steps = str2double(len_txt);
    len_pos = linspace(-scan_len/2, scan_len/2, len_steps);
    octmscan.len_pos = len_pos;
    numL = len_steps;
    params.x_n = numL;
    params.x_pos = len_pos;

    [idx, idx2] = regexp(scanprms_txt, 'width\='); % width will be 0 (widthSteps = 1) for 2-d cross-sections
    width_txt = scanprms_txt(idx2+1:idx2+20);
    width_txt = strtok(width_txt);
    scan_width = str2double(width_txt);
    params.y = scan_width;

    [idx, idx2] = regexp(scanprms_txt, 'widthSteps\=');
    width_txt = scanprms_txt(idx2+1:idx2+20);
    width_txt = strtok(width_txt);
    width_steps = str2double(width_txt);
    width_pos = linspace(-scan_width/2, scan_width/2, width_steps);
    octmscan.width_pos = width_pos;
    numW = width_steps;
    params.y_n = numW;
    
    fname = fullfile(tmpDir, 'ProcOpts.txt');
    fid = fopen(fname, 'r');
    scanprms_txt = fread(fid, '*char')';
    fclose(fid);
    
    zRes_txt = 'zRes= ';
    aspectRatio_txt = 'correctAspectRatio= ';
    refrI_txt = 'refractiveIndex= ';
    cw_txt = 'centerWavelength= ';
    isOCM_txt = 'isOCM= ';
    dk_txt = 'dk= ';
    zROI_txt = 'zROI= ';
    nFFT_txt = 'nFFT= ';
    
    fid = fopen(fname);
    aa = fscanf(fid,'%c',Inf);
    zRes_txt_i = strfind(aa,zRes_txt);
    aspectRatio_txt_i = strfind(aa,aspectRatio_txt);
    refrI_txt_i = strfind(aa,refrI_txt);
    cw_txt_i = strfind(aa,cw_txt);
    isOCM_txt_i = strfind(aa,isOCM_txt);
    dk_txt_i = strfind(aa,dk_txt);
    zROI_txt_i = strfind(aa,zROI_txt);
    nFFT_txt_i = strfind(aa,nFFT_txt);
    
    params.z_res = str2num(aa(zRes_txt_i+length(zRes_txt):aspectRatio_txt_i-1)) * 10^-6; % z resoluion
    params.refractive_index = str2num(aa(refrI_txt_i+length(refrI_txt):cw_txt_i-1)); % refractive index
    params.center_wavelength = str2num(aa(cw_txt_i+length(cw_txt):isOCM_txt_i-1)); % center wavelength (nm)
    params.dk = str2num(aa(dk_txt_i+length(dk_txt):zROI_txt_i-5)); % dk
    params.nFFT = str2num(aa(nFFT_txt_i+length(nFFT_txt):nFFT_txt_i+length(nFFT_txt)+5)); % dk
    
    zROI = aa(zROI_txt_i+length(zROI_txt):nFFT_txt_i-1);
    zROI1 = strfind(zROI,'[');
    zROI2 = strfind(zROI,']');
    params.z_roi = str2num(zROI(zROI1:zROI2));
    params.z_n = 1 + params.z_roi(2) - params.z_roi(1);
end