function [micData] = readMicData(fileName)

    fid = fopen(fileName);
    s = fread(fid, 6, 'uchar');   % 'magic' string which  should be x93NUMPY
    ver_maj = fread(fid, 1, 'uint8');  % major version
    ver_min = fread(fid, 1, 'uint8');  % minor version
    hdr_len = fread(fid, 1, 'uint16'); % header length
    % num_hdr_bytes = 16 * ceil((hdr_len+4)/16)
    num_hdr_bytes = hdr_len;
    %fprintf('\nhdr_len= %d num_hdr_bytes= %d', hdr_len, num_hdr_bytes);
    hdr = fread(fid, num_hdr_bytes, 'uchar'); 
    hdr_s = char(hdr)';
    % fprintf('\nhdr= %s', hdr_s);
    s1 = regexp(hdr_s, '''shape'': \((.*)\)', 'tokens');
    s = char(s1{1, 1});
    sz = str2double(s);
    micData = fread(fid, sz, 'double');
    fclose(fid);
    
    
end