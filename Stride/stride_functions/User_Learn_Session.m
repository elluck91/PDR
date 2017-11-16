function [ state, manual_data ] = User_Learn_Session(state, stateN, steps, span, samp_curr, manual_data, TEST_CONVERGENCE)

Tin     = span(1);
Tout    = span(2);

if samp_curr == Tin 
    % User is starting a learning session --> should enable learning block
    % At this time, knowing the user intentions, set the references
    state.CalRef.LastValidTime  = steps.time;
    state.CalRef.LastValidStep  = steps.Nsteps;
    state.CalRef.LastDistance   = steps.dist_cm;
    state.CalRef.refStep        = state.CalRef.LastValidStep;
    state.CalRef.refTime        = state.CalRef.LastValidTime;
    state.CalRef.refDist_cm     = state.CalRef.LastDistance;
    state.model                 = 2;  % learning mode initialised
end
if samp_curr >= Tin  && samp_curr <= Tout  && (stateN.accdata.N <= 3 || stateN.accdata.N >= 48) % first samples after Step update
    state.model                 = 2;  % learning mode initialised
    [ state ] = LearningModule(state, steps);
end     
if samp_curr == Tout  
    % At the end of the learning session, user includes ground thruth
    % values, which can be compared with the one processed        
    state.manual_input.Nsteps     = manual_data(1);       % step number is computed or directly set by the user
    state.manual_input.Time       = manual_data(2);       % automatically computed by the algorithm
    state.manual_input.Dist_cm    = manual_data(3);       % could be included or not by the user, so set 0
    state.manual_input.activity   = manual_data(4);
    state.manual_input.flag       = 1;
    
    % Compare processed data with user input - If Segment passes ckecks,
    % run the UpdateModel function (by setting CalRef.enable = 1)
    if state.manual_input.Nsteps > 0   % the User is including also the number of steps
        err_steps   = 1/state.manual_input.Nsteps*abs(state.manual_input.Nsteps - (state.CalRef.LastValidStep - state.CalRef.refStep + sum(state.CalRef.seg_steps)));
    else
        err_steps   = 0;
    end
    err_time    = (abs(state.manual_input.Time - ...
        (state.CalRef.LastValidTime - state.CalRef.refTime + sum(state.CalRef.seg_time(find(state.CalRef.seg_steps > 0):end)))))...
        /state.manual_input.Time;
    if ~TEST_CONVERGENCE
        if err_steps < 0.05 && err_time < 0.08 && state.CalRef.stepStd < strideLengthConsts.freq_std_thresh
            state.CalRef.enable       = 1;    % if User is including information too much different from the computed one, do not allow the updating phase
        end
    else
        state.CalRef.enable       = 1;    % if User is including information too much different from the computed one, do not allow the updating phase
        
    end
        
    manual_data = [];
    
    state.CalRef.seg_dist   = 0;
    state.CalRef.seg_steps  = 0;
    state.CalRef.seg_time   = 0;
    
end