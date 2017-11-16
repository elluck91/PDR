function [ slope_in_range ] = slope_range(state, info_freq_old, info)

% Slope range is computed as the derivative of the model curve
% at the frequency point considered at the previous step (could be replaced by an error on
% the difference between the old model and the new point)
slope_max   = (2*state.walkModel.x2*info_freq_old + state.walkModel.x)*1.5;
slope_min   = (2*state.walkModel.x2*info_freq_old + state.walkModel.x)/1.5;

% N.B: to compare the last SL, use the updated model instead of
% the manual computed one from extracted segments
if info_freq_old < strideLengthConsts.freqRun_Hz
    sl_old      = (state.walkModel.x2*info_freq_old^2 + state.walkModel.x*info_freq_old + state.walkModel.x0)/100;
else
    sl_old      = (state.runningModel.x2*info_freq_old^2 + state.runningModel.x*info_freq_old + state.runningModel.x0)/100;
end
% other way to compute, but wrong --> info_dist_old/info_step_old;

sl_curr     = info.segment_distance/info.segment_steps;

if state.CalRef.meanFreq > info_freq_old
    slope_curr  = (sl_curr - sl_old)/(state.CalRef.meanFreq - info_freq_old)*100;
else
    slope_curr  = (sl_curr - sl_old)/(-state.CalRef.meanFreq + info_freq_old)*100;
end


if slope_curr < slope_max  && slope_curr > slope_min
    slope_in_range = 1;
else
    slope_in_range = 0;
end