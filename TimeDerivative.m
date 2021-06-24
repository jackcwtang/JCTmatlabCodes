function [Delta] = TimeDerivative(data,interval)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
dt = 1/data.SweepFrequency;
% total_t= dt*length(data.time);
sample_interval = round(interval/dt);
tmp = data.mag.*exp(1i.*(data.phase));
tmp_delta = tmp(1:(end-sample_interval),:,:)-tmp((sample_interval)+1:end,:,:);
Delta = data;
Delta.interval = interval;
Delta.dmag = abs(tmp_delta);
Delta.dphase = angle(tmp_delta);
end

