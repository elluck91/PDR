function [ state ] = updateStepDetection(state, data, logging)

if(logging.unitTestLogging.stepDetection > -1)  % If logging enabled
    writeLine(logging.unitTestLogging.stepDetection, createMsg(data.acc.procBuffer, 0, memsUnitTestIDs.uDataAcc_procBuffer));
    writeLine(logging.unitTestLogging.stepDetection, createMsg(state.stepResults.Nsteps, 0, memsUnitTestIDs.uStepState_NumberOfSteps));
end

% Run main processing
[state, results]    =  runStepDetection(state, data,logging);

% Update the results
state   = updateStepDetectionState(state, results);
end

% function to update the state with results
function state  = updateStepDetectionState(state, results)
if results.nSteps > 0   % if any step is detected in the segment just processed
    for n = 1:results.nSteps
        % hard for user to know how many steps are detected in this epoch,
        % better to keep only which are detected in history
        state.stepResults.Nsteps    = state.stepResults.Nsteps + 1;
        state.stepResults.NHist     = min([state.stepResults.NHist + 1, state.stepResults.NHistMax]);
        index   = state.stepResults.bufferIndex;
        state.stepResults.steps(index + 1).time     = results.time(n);
        state.stepResults.steps(index + 1).freq     = results.stepFreq(n);
        state.stepResults.steps(index + 1).conf     = results.stepFreqConf(n);
        state.stepResults.bufferIndex               = mod(state.stepResults.bufferIndex + 1, state.stepResults.NHistMax);
        
        state.stepsRes.nSteps       = state.stepResults.Nsteps;
        state.stepsRes.stepFreq     = results.stepFreq(1:n);
        state.stepsRes.stepFreqConf = results.stepFreqConf(1:n);
        state.stepsRes.time         = results.time(1:n);
%         state.stepsRes.value        = 
    end
end
end