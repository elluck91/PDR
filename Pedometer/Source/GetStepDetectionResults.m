function [ totalSteps, newStepsReported, stepsInfo] = GetStepDetectionResults( state )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
totalSteps  = state.stepResults.Nsteps;
newStepsReported    = state.stepResults.NHist;
if newStepsReported>0
    stepsInfo(1:newStepsReported)= emptyStepRes();
    for i = 1:newStepsReported
        stepsInfo(i).time   = state.stepResults.steps(i).time;
        stepsInfo(i).freq   = state.stepResults.steps(i).freq;
        stepsInfo(i).conf   = state.stepResults.steps(i).conf;        
    end
else
    stepsInfo = [];
end
end

