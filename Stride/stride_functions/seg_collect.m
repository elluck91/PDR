function [ state ] = seg_collect(state, steps)

currTime    = steps.time;
dist_cm     = steps.dist_cm;
Nsteps      = steps.Nsteps;

% Define segments to be used to update the model

state.CalRef.seg_steps(end + 1)    = Nsteps   - state.CalRef.refStep;
state.CalRef.seg_time(end + 1)     = currTime - state.CalRef.refTime;
state.CalRef.seg_dist(end + 1)     = dist_cm  - state.CalRef.refDist_cm;
