function [ dev ] = checkForDev( state, info )
% This function is meant to avoid that in the updating buffer could be
% included data points with could bias or degrade the computation of the
% novel model. To do this, we can add a deviation check on the new extrated
% point in comparison with the default model and the last computed one.

freq        = info.segment_steps/info.segment_time;
stride      = info.segment_distance/info.segment_steps*100;
% Parameters of the novel computed model could be compared with the default
% one. Default model represents a genral purpose model, which could be
% viewd as the most general model that could be a good approx, ideally
% independent, from the specific user

if freq > strideLengthConsts.freqRun_Hz
    flag_walk   = 0;
    flag_run    = 1;
else
    flag_walk   = 1;
    flag_run    = 0;
end


if flag_walk
    default_model   = strideLengthConsts.walkModel_x0 + ...
                      strideLengthConsts.walkModel_x*freq + ...
                      strideLengthConsts.walkModel_x2*freq^2;
                  
    last_model      = state.walkModel.x0 + ...
                      state.walkModel.x*freq + ...
                      state.walkModel.x2*freq^2;
elseif flag_run
    default_model   = strideLengthConsts.runModel_x0 + ...
                      strideLengthConsts.runModel_x*freq + ...
                      strideLengthConsts.runModel_x2*freq^2;
                  
    last_model      = state.runningModel.x0 + ...
                      state.runningModel.x*freq + ...
                      state.runningModel.x2*freq^2;
end

             
dev     = min(abs(stride - last_model)/last_model, abs(stride - default_model)/default_model);