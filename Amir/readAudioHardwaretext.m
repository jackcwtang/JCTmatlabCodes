function [Gain,Sen,SR,micType] = readAudioHardwaretext(tmpDir)

rootDir = '.';

if nargin<1
    tmpDir = rootDir;
end

params = [];

%% Audio parameters
fname = strcat(tmpDir, '/AudioHardware.txt');

if exist(fname)
    fid = fopen(fname, 'r');
    tline = fgetl(fid);
    while ischar(tline)
        %disp(tline)
        %Gain
        if contains(tline,'Mic Gain'),
            idx = 1;
            Gain = [];
            tline = tline(9:end);
            [numStr, cnt, err, idx] = sscanf(tline, '%s', 1);
            k = 0;
            while(~isempty(numStr) && k < 1000)
                Gain = [Gain str2double(numStr)];
                tline = tline(idx:end);
                [numStr, cnt, err, idx] = sscanf(tline, '%s', 1);
                k = k + 1;
            end
            
            Gain=Gain(2:end);
        end
        %Sensitivity
        if contains(tline,'Mic mVolts per Pascal'),
            idx = 1;
            Sen = [];
            tline = tline(22:end);
            [numStr, cnt, err, idx] = sscanf(tline, '%s', 1);
            k = 0;
            while(~isempty(numStr) && k < 1000)
                Sen = [Sen str2double(numStr)];
                tline = tline(idx:end);
                [numStr, cnt, err, idx] = sscanf(tline, '%s', 1);
                k = k + 1;
            end
            
            Sen=Sen(2:end);
        end
        
        %Sampling Rate
        
        if contains(tline,'Output Rate='),
            idx = 1;
            SR = [];
            tline = tline(12:end);
            [numStr, cnt, err, idx] = sscanf(tline, '%s', 1);
            k = 0;
            while(~isempty(numStr) && k < 1000)
                SR = [SR str2double(numStr)];
                tline = tline(idx:end);
                [numStr, cnt, err, idx] = sscanf(tline, '%s', 1);
                k = k + 1;
            end
            
            SR=SR(2:end);
        end
        
        if contains(tline,'Mic= '),
            idx = 1;
            dumy = [];
            tline = tline(4:end);
            [numStr, cnt, err, idx] = sscanf(tline, '%s', 1);
            k = 0;
            while(~isempty(numStr) && k < 1000)
                dumy = [dumy numStr];
                tline = tline(idx:end);
                [numStr, cnt, err, idx] = sscanf(tline, '%s', 1);
                k = k + 1;
            end
            
            micType=dumy(2:end);
        end
        
        
        tline = fgetl(fid);
    end
end

end