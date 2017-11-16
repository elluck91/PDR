function [ state ] = replacePoint_buffer( state, info, ind_replace)


state.strideCalInfo.Nsteps(ind_replace)    = info.segment_steps;
state.strideCalInfo.dTime(ind_replace)     = info.segment_time;
state.strideCalInfo.Dist_cm(ind_replace)   = info.segment_distance;

state.strideCalInfo.f_sum(ind_replace)     = state.CalRef.stepfreqSum;
state.strideCalInfo.f2_sum(ind_replace)    = state.CalRef.stepfreq_2_Sum;
state.strideCalInfo.freq_std(ind_replace)  = state.CalRef.stepStd;

try
    state.strideCalInfo.step_type(ind_replace) = info.activity;
catch
    state.strideCalInfo.step_type(ind_replace) = state.CalRef.Activity_curr;
end