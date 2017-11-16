function [ state ] = resetCalstate(state)

state.CalRef.refDist_cm     = state.CalRef.LastDistance;
state.CalRef.refStep        = state.CalRef.LastValidStep;
state.CalRef.refTime        = state.CalRef.LastValidTime;
state.CalRef.f_elems        = 0;
state.CalRef.meanFreq       = 0;
state.CalRef.stepfreq_2_Sum = 0;
state.CalRef.stepfreqSum    = 0;
state.CalRef.stepStd        = 0;
end