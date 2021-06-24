function [TDPhase_trials_avg, TDPhase_all_trials] = read_tdphase_bmscan(file_name, do_plot)
%READ_TDPHASE_BMSCAN Read data saved in FastBMScan protocol
%   

    if nargin == 0
      error(['Function usage: read_tdphase_bmscan(file_name, [do_plot])' ...
             '\nwhere do_plot is true or false for plotting (some) data']);
    end
    if nargin == 1
      do_plot = false;
    end
    %file_name = 'BMscan TD Phase 4.00 kHz 50.0 dB frame 0';
    fid = fopen(file_name, 'r');

    % read average data (averaging of all trials)
    trial_time = fread(fid, 1, 'double');
    region_shape = fread(fid, 2, 'uint32');
    TDPhase_trials_avg = fread(fid, prod(region_shape), 'double');
    TDPhase_trials_avg = reshape(TDPhase_trials_avg, region_shape');
    % read all trials data
    TDPhase_all_trials = [];
    all_trials_shape = fread(fid, 3, 'uint32');
 if ~isempty(all_trials_shape)
    all_trials_shape = [all_trials_shape(3); all_trials_shape(1:2)];
 end
    if ~(feof(fid) || isempty(all_trials_shape))
        TDPhase_all_trials = fread(fid, prod(all_trials_shape), 'double');
        TDPhase_all_trials = reshape(TDPhase_all_trials, all_trials_shape');
    end

    fclose(fid);
    if do_plot
      figure;
      plot(TDPhase_trials_avg);
      figure;
      hold on;
      for i=1:10%all_trials_shape(1)/4
        plot(TDPhase_all_trials(i,:)+i*100);
      end
    end
end