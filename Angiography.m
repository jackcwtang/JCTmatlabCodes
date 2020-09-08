%%  Read in the raw OCT data
option.command = '';
OCT_data = ProcessSpectralInterferogram(4096, option);
%4096 for Insight lasers
%2560 for Santec laser