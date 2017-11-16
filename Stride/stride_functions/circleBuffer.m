function [ state ] = circleBuffer(state, info)

    state.strideCalInfo.Nsteps(1:end-1)     = state.strideCalInfo.Nsteps(2:end);
    state.strideCalInfo.Nsteps(end)         = info.segment_steps;
    
    state.strideCalInfo.dTime(1:end-1)      = state.strideCalInfo.dTime(2:end);
    state.strideCalInfo.dTime(end)          = info.segment_time;
    
    state.strideCalInfo.Dist_cm(1:end-1)    = state.strideCalInfo.Dist_cm(2:end);
    state.strideCalInfo.Dist_cm(end)        = info.segment_distance;
        
    state.strideCalInfo.f_sum(1:end-1)      = state.strideCalInfo.f_sum(2:end);
    state.strideCalInfo.f_sum(end)          = state.CalRef.stepfreqSum;
    
    state.strideCalInfo.f2_sum(1:end-1)     = state.strideCalInfo.f2_sum(2:end);
    state.strideCalInfo.f2_sum(end)         = state.CalRef.stepfreq_2_Sum;
    
    state.strideCalInfo.freq_std(1:end-1)   = state.strideCalInfo.freq_std(2:end);
    state.strideCalInfo.freq_std(end)       = state.CalRef.stepStd;
    
    state.strideCalInfo.step_type(1:end-1)  = state.strideCalInfo.step_type(2:end);
    
    try
        state.strideCalInfo.step_type(end)  = info.activity;
    catch
        state.strideCalInfo.step_type(end)  = state.CalRef.Activity_curr;
    end