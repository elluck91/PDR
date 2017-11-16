function [ state,ifResultedUpdated ] = RunStepDetectionModule( state, AccX, AccY, AccZ, time )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

state.accdata.N     = state.accdata.N + 1;
state.accdata.t(state.accdata.N)     = time;
state.accdata.x(state.accdata.N)     = AccX;
state.accdata.y(state.accdata.N)     = AccY;
state.accdata.z(state.accdata.N)     = AccZ;
state.accdata.valid(state.accdata.N) = stepConsts.TRUE;
ifResultedUpdated   = 0;

% Wait until collected approx one second (n samples based on sampling rate)
if state.accdata.N == stepConsts.samplingRate;      % processing data sample by sample 
    data    = state.accdata;
    % enable debug
    logging.unitTestLogging.stepDetection   = -1;
    logging.dbgLogging.stepDetection        = -1;
    
    % Update step detection state
    state   = updateStepDetection(state, data, logging);
    ifResultedUpdated   = 1;
    
    % Reset for the next One Second segment data
    state.accdata.N     = 0;
end

end

