function [state, results] =  runStepDetection(state, data, logging)
results     = emptyStepRes();

% Better to call I16 data here 
accdata     = data;
for n = 1:accdata.N
    % check the data validity here - process sample by sample
    if (accdata.valid(n) == 1)
        state.sampleCount   = state.sampleCount + 1;
        
        % Calculating acc norm of each sample
        normAcc     = sqrt(accdata.x(n)^2 + accdata.y(n)^2 + accdata.z(n)^2);
        
        % Update auto covariance buffer
        state.normAccAutoCovWindow(1: stepConsts.normAccAutoCovWinSize - 1)  = ...
            state.normAccAutoCovWindow(2: stepConsts.normAccAutoCovWinSize);
        state.normAccAutoCovWindow(stepConsts.normAccAutoCovWinSize)         = normAcc;
        
        % Update norm acc energy buffer and if it is overlap energy, then calculate energy
        state.normAccEnergyBuffer(mod(state.sampleCount - 1, stepConsts.windowLength) + 1) = normAcc - 1;  % subtrack g
        % when overlap (== 50) and higher than 100, compute the energy norm of last 100 samples 
        if mod(state.sampleCount, stepConsts.overlap) == 0 && state.sampleCount > stepConsts.windowLength
            state.energyInNorm  = mean((state.normAccEnergyBuffer).^2);
        end
        
        % Filter the data for each filter
        [state, ~]      = FilterData(state, normAcc, stepConsts.bFiltDefault, stepConsts.aFiltDefault,stepConsts.DEFAULT);
        [state, ~]      = FilterData(state, normAcc, stepConsts.bFiltA, stepConsts.aFiltA, stepConsts.FILTER_A);
        [state, ~]      = FilterData(state, normAcc, stepConsts.bFiltB, stepConsts.aFiltB, stepConsts.FILTER_B);
        [state, ~]      = FilterData(state, normAcc, stepConsts.bFiltC, stepConsts.aFiltC, stepConsts.FILTER_C);
        [state, ~]      = FilterData(state, normAcc, stepConsts.bFiltD, stepConsts.aFiltD, stepConsts.FILTER_D);
        
%         [state, ~]      = FilterData(state, normAcc, stepConsts2.bFiltDefault, stepConsts2.aFiltDefault,stepConsts.DEFAULT);
%         [state, ~]      = FilterData(state, normAcc, stepConsts2.bFiltA, stepConsts2.aFiltA, stepConsts.FILTER_A);
%         [state, ~]      = FilterData(state, normAcc, stepConsts2.bFiltB, stepConsts2.aFiltB, stepConsts.FILTER_B);
%         [state, ~]      = FilterData(state, normAcc, stepConsts2.bFiltC, stepConsts2.aFiltC, stepConsts.FILTER_C);
%         [state, ~]      = FilterData(state, normAcc, stepConsts2.bFiltD, stepConsts2.aFiltD, stepConsts.FILTER_D);
        
        state.filterBufferLocation   = mod(state.filterBufferLocation + 1, stepConsts.filterBufferSize);   
        
        % Filter the data using averaging
        [state, ~]      = ApplyAveragingFilter(state, normAcc);        
         
        % Determine using energy if person can be walking
        if state.energyInNorm > stepConsts.minWalkingEnergy
            state.ifWalking     = stepConsts.TRUE;
        else
            state.ifWalking     = stepConsts.FALSE;
        end
        
        % If the person is walking, update walking duration and reset not
        % walking duration. Otherwise vice versa
        if state.ifWalking == stepConsts.TRUE
            state.notWalkingDuration        = 0;
            state.walkingStartedDuration    = min(state.walkingStartedDuration + 1, stepConsts.upperLimitOnWalkingDuration);
        else
            state.walkingStartedDuration    = 0;
            state.notWalkingDuration        = min(state.notWalkingDuration + 1,stepConsts.upperLimitOnNotWalkingDuration);
        end
        
        if state.ifWalking == stepConsts.TRUE
            
            % Estimate if the current filtered data has peaks
            [state, ifPeakDetected]     = GetPeaksInFilteredData(state, state.currentlySelectedFilter);
            
            % If a negative peak is detected, check if it is a step. If yes,
            % then update the step frequency
            if ifPeakDetected  == stepConsts.NEGATIVE_PEAK
                if CheckForStep(state, state.currentlySelectedFilter) == stepConsts.TRUE
                    state.samplesSinceLastStep  = stepConsts.STEP_EVENT_TO_BE_UPDATED;      % reset the number of samples from last step is a new step is detected
                    state   = UpdateStepFrequencyWhenStepFound(state);      % update also step frequency
                end
            end
            
            % Time of step event estimation
            if state.samplesSinceLastStep ~= stepConsts.STEP_EVENT_UPDATED
                if ifPeakDetected == stepConsts.POSITIVE_PEAK
                   state.samplesSinceLastStep   = stepConsts.STEP_EVENT_UPDATED;
                   lastStepEventDetected        = state.lastStepEpoch;
                   
                   if (state.sampleCount - lastStepEventDetected) + stepConsts.searchDelaySinceLastStep >= stepConsts.averagingFilteredSearchWindow
                       startTag     = 1;
                   else
                       startTag     = stepConsts.averagingFilteredSearchWindow - (state.sampleCount - (lastStepEventDetected + stepConsts.searchDelaySinceLastStep));
                   end
                   [localNegPeaks, localPosPeaks] = GetAllPeaksInSignal(state.averagingFilteredOutput(startTag: stepConsts.averagingFilteredSearchWindow), stepConsts.searchWindowForAvgFilteredPeak,stepConsts.threshNegPeak,stepConsts.threshPosPeak);
                   
                   % check for special case
                   if state.sampleCount - lastStepEventDetected > 2*stepConsts.samplingRate
                       [~,index]    = min(localNegPeaks(:,2));
                       lastStepEventDetected    = state.sampleCount - stepConsts.averagingFilteredSearchWindow + startTag + localNegPeaks(index,1) - stepConsts.correctionDueToAveraging;
                   else
                       possibleStepEvents       = state.sampleCount - stepConsts.averagingFilteredSearchWindow + startTag + localNegPeaks(:,1);
                       possibleStepDurations    = possibleStepEvents - lastStepEventDetected;
                       expectedStepDuration     = stepConsts.samplingRate/state.stepFrequency.value;
                       [~,index]                = min(abs(possibleStepDurations - expectedStepDuration));
                       % Refine the step detection. if nearby peaks are far less than
                       % current peak value, then declare that peak as the latest peak.
                       if length(localNegPeaks(:,1)) > 1
                           % Check with PREVIOUS peak
                           if index > 1
                               previousPeakValue    = localNegPeaks(index - 1,2);
                               currentPeakValue     = localNegPeaks(index, 2);
                               durationDifference   = localNegPeaks(index, 1) - localNegPeaks(index - 1,1);
                               if durationDifference < stepConsts.maxDurationDifferenceBetweenClosePeaks && ...
                                       (currentPeakValue - previousPeakValue) > stepConsts.minValueDifferenceBetweenClosePeaks
                                   index    = index - 1;
                               end
                           end
                           % Check with FOLLOWING peak
                           if index + 1 <= length(localNegPeaks(:,1))
                               nextPeakValue        = localNegPeaks(index + 1, 2);
                               currentPeakValue     = localNegPeaks(index, 2);
                               durationDifference   = localNegPeaks(index + 1, 1) - localNegPeaks(index, 1);
                               if durationDifference < stepConsts.maxDurationDifferenceBetweenClosePeaks && ...
                                       (currentPeakValue - nextPeakValue) > stepConsts.minValueDifferenceBetweenClosePeaks
                                   index    = index + 1;
                               end
                           end
                       end
                       lastStepEventDetected    = state.sampleCount - stepConsts.averagingFilteredSearchWindow + ...
                           startTag + localNegPeaks(index, 1) - stepConsts.correctionDueToAveraging;
                   end
                   
                   results.nSteps       = results.nSteps + 1;
                   results.time         = [results.time, lastStepEventDetected/stepConsts.samplingRate];
                   results.stepFreq     = [results.stepFreq, state.stepFrequency.value];
                   results.stepFreqConf = [results.stepFreqConf, state.stepFrequency.confidence];
                   
                   state.lastStepEpoch  = lastStepEventDetected;
                end
            end
         
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % If walking has happened for last stable walking session and
            % confidence is still less, turn on autocorrelation function to get
            % step frequency
            if state.walkingStartedDuration == stepConsts.upperLimitOnWalkingDuration && ...
                state.stepFrequency.confidence < stepConsts.leastConfidenceToKeepCurrentFilter
    
                [ state ] = AutoCorr_freq( state );
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
        end
        
        % Reset to default filter person is not walking for some time
        if state.notWalkingDuration == stepConsts.upperLimitOnNotWalkingDuration
            state.currentlySelectedFilter   = stepConsts.DEFAULT;
        end
        
        % Update step frequency
        state   = UpdateStepFrequency(state);
    end
end

% Reset sampleCount based on time
if accdata.t(n) - state.sampleCount/stepConsts.samplingRate > 2*(1/stepConsts.samplingRate)
    state.sampleCount = round(accdata.t(n)*stepConsts.samplingRate);
end

% Logging debugging output - enabling
if logging.dbgLogging.stepDetection > 0
    if isempty(state.dbg)
        state.dbg   = results;
    else
        L   = length(state.dbg);
        state.dbg(L + 1, :)  = results;
    end
end

% if any step detected
if accdata.N > 0
   state.stepResults.Time   = state.sampleCount*stepConsts.samplingRate;
   state.stepResults.Norm   = normAcc;
end

end  % end Main Function


%-------------------
% Function to filter data for a given transfer function
% Inputs
% -- State for step detection
% -- x or Input data
% -- bFilt, aFilt    Filter coefficients for transfer function
% -- filter Index    Filter index defines which filter from the filter array
% Outputs
% -- Updated state
%-------------------
function [state, filteredValue]  = FilterData(state, inputData, bFilt, aFilt, filterIndex)

filterBufferSize    = stepConsts.filterBufferSize;
currentIndex        = mod(state.filterBufferLocation, filterBufferSize) + 1;

state.filterX(currentIndex)             = inputData;
state.filterY(currentIndex,filterIndex) = 0;

for j = 0:filterBufferSize - 1
    n1  = j + 1;
    n2  = mod(filterBufferSize + state.filterBufferLocation - j, filterBufferSize) + 1;
    state.filterY(currentIndex, filterIndex)    = state.filterY(currentIndex, filterIndex) + bFilt(n1)*state.filterX(n2);
    if j > 0
        state.filterY(currentIndex, filterIndex)    = state.filterY(currentIndex, filterIndex) - aFilt(n1)*state.filterY(n2,filterIndex);
    end
end
filteredValue   = state.filterY(currentIndex, filterIndex);
end


%-------------------
% Function to filter data for an averaging filter
% Inputs
% -- State for step detection
% -- x or Input data
% Outputs
% -- Updated state
%-------------------
function [state, avgFilterOutput]    = ApplyAveragingFilter(state,inputData)
% update buffers
state.dataForAveragingFiltered(1: stepConsts.averagingFilteredWindow - 1)   = state.dataForAveragingFiltered(2: stepConsts.averagingFilteredWindow);
state.dataForAveragingFiltered(stepConsts.averagingFilteredWindow)          = inputData;

state.averagingFilteredOutput(1: stepConsts.averagingFilteredSearchWindow - 1)  = state.averagingFilteredOutput(2: stepConsts.averagingFilteredSearchWindow);
state.averagingFilteredOutput(stepConsts.averagingFilteredSearchWindow)         = mean(state.dataForAveragingFiltered);

% compute average
avgFilterOutput     = state.averagingFilteredOutput(stepConsts.averagingFilteredSearchWindow);
end


%-------------------
% General Function to get all peaks in a signal
% Inputs
% -- signal
% -- win : window in which derivative is checked
% -- threshNegPeak: peak value should be below this thresh to detect a negative peak
% -- threshPosPeak: peak value should be above this thresh to detect a positive peak
% Outputs
% -- localNegPeaks: list of negative peaks in the signal
% -- localPosPeaks: list of positive peaks in the signal
%-------------------
function [localNegPeaks,localPosPeaks]  = GetAllPeaksInSignal(signal, win, threshNegPeak, threshPosPeak)
localNegPeaks   = [];
localPosPeaks   = [];

diffSignal      = diff(signal);

for i = 0:length(diffSignal) - win
    if max(diffSignal(i + 1:i + win/2)) < 0 && min(diffSignal(i + win/2 + 1:i + win)) > 0 && signal(i + win/2 + 1) < threshNegPeak
        localNegPeaks   = [localNegPeaks; i + win/2 + 1, signal(i + win/2 + 1)];
    end
    if min(diffSignal(i + 1:i + win/2)) > 0 && max(diffSignal(i + win/2 + 1:i + win)) < 0 && signal(i + win/2 + 1) > threshPosPeak
        localPosPeaks   = [localPosPeaks; i + win/2 + 1, signal(i + win/2 + 1)];
    end
end
if isempty(localNegPeaks)
    [minValue, index]   = min(signal);
    localNegPeaks       = [index, minValue];
end
if isempty(localPosPeaks)
    [maxValue, index]   = max(signal);
    localPosPeaks       = [index, maxValue];
end
end

%---------------------------------------
% Function to get peaks in filtered data
% Inputs
% -- State for step detection
% -- filter Index - Filter index defines which filter from the filter array
% Outputs
% -- Updated state
% -- Flag if peak is detected
%---------------------------------------
function [state, ifPeakDetected] = GetPeaksInFilteredData(state, filterIndex)

filterBufferSize        = stepConsts.filterBufferSize;
diffSignalBufferSize    = stepConsts.diffSignalBufferSize; % window on which is evaluated convexity (peak detection)

currentIndex            = mod(filterBufferSize + state.filterBufferLocation - 1, filterBufferSize) + 1;
lastIndex               = mod(filterBufferSize + state.filterBufferLocation - 2, filterBufferSize) + 1;

% compute diff (derivatives)
state.diffSignal(1:diffSignalBufferSize - 1, filterIndex)   = state.diffSignal(2:diffSignalBufferSize, filterIndex);
state.diffSignal(diffSignalBufferSize, filterIndex)         = state.filterY(currentIndex, filterIndex) - state.filterY(lastIndex, filterIndex);

win         = diffSignalBufferSize;
peakFound   = 0;
diffSignal  = state.diffSignal(:, filterIndex);
% Check if in the buffer data we find the first part decreasing and the
% second increasing ---> minimum point
if max(diffSignal(1:win/2)) < 0 && min(diffSignal(win/2 + 1:win)) > 0
    peakFound   = -1;   % Minimum (peak) found
end
if min(diffSignal(1:win/2)) > 0 && max(diffSignal(win/2 + 1:win)) < 0
    peakFound   = 1;    % Maximum (peak) found
end

ifPeakDetected  = 0;
if peakFound ~= 0       % positive or negative peaks found
    if state.peakInZone(filterIndex) == 0
        ifPeakDetected  = peakFound;
        peakIndex       = mod(filterBufferSize + state.filterBufferLocation - win/2, filterBufferSize) + 1;
        state.peakZoneValueAndLocationLast(filterIndex, 1)  = state.peakZoneValueAndLocation(filterIndex, 1);
        state.peakZoneValueAndLocationLast(filterIndex, 2)  = state.peakZoneValueAndLocation(filterIndex, 2);
        state.peakZoneValueAndLocation(filterIndex, 1)      = state.filterY(peakIndex, filterIndex);
        state.peakZoneValueAndLocation(filterIndex, 2)      = state.sampleCount - diffSignalBufferSize/2;
    end
    state.peakInZone(filterIndex)   = 1;
else
    if abs(state.filterY(currentIndex, filterIndex) - state.peakZoneValueAndLocation(filterIndex, 1)) ...
            > stepConsts.minZoneDiffValue
        state.peakInZone(filterIndex)   = 0;
    end
end
end



%-------------------------------------------------
% Function to identify if step is there in pattern
% Inputs
% -- State for step detection
% -- filter Index - Filter index defines which filter from the filter array
% Outputs
% -- Updated state
% -- Flag if step is detected
%-------------------------------------------------
function ifStepFound    = CheckForStep(state,filterIndex)

p2pThresh           = stepConsts.p2pThresh;         % defined minum peak 2 peak threshold (min max)
durationMinThresh   = stepConsts.durationMinThresh; % also define min and max duration
durationMaxThresh   = stepConsts.durationMaxThresh;

filterSettlingDuration  = stepConsts.filterSettlingDuration;

% compute p2p and duration
p2pValue    = state.peakZoneValueAndLocationLast(filterIndex,1) - state.peakZoneValueAndLocation(filterIndex,1);
duration    = state.peakZoneValueAndLocation(filterIndex,2) - state.peakZoneValueAndLocationLast(filterIndex,2);

ifStepFound = 0;
if p2pValue > p2pThresh && ...
        duration < durationMaxThresh && ...
        duration > durationMinThresh && ...
        state.sampleCount > filterSettlingDuration
    ifStepFound     = 1;
end
end


%-----------------------------------------------------
% Function to Update Step Frequency When Step is Found
% Inputs
% -- State for step detection
% Outputs
% -- Updated state
%-----------------------------------------------------
function state  = UpdateStepFrequencyWhenStepFound(state)

if state.stepFrequency.lastStepDetected == 0
    state.stepFrequency.lastStepDetected    = state.sampleCount;
else
    stepFrequencyValue  = stepConsts.stepFrequencySamplingRate/(state.sampleCount - state.stepFrequency.lastStepDetected);
    state.stepFrequency.lastStepDetected    = state.sampleCount;
    % compute confidence in computing step frequency --> more the samples,
    % higher the confidence
    state.stepFrequency.confidence          = min([state.stepFrequency.confidence + 1, stepConsts.stepFrequencyMaxConfidence]);
    state.stepFrequency.lastStepsIncluded   = min([state.stepFrequency.lastStepsIncluded + 1, stepConsts.stepFrequencyMaxNoOfSteps]);
    state.stepFrequency.currentValue        = stepFrequencyValue;
    if state.stepFrequency.lastStepsIncluded < stepConsts.stepFrequencyMaxNoOfSteps
        state.stepFrequency.lastStepFrequencyBuffer(state.stepFrequency.lastStepsIncluded)  = stepFrequencyValue;
        state.stepFrequency.value   = sum(state.stepFrequency.lastStepFrequencyBuffer(1:state.stepFrequency.lastStepsIncluded))/state.stepFrequency.lastStepsIncluded;
    else
        % Update buffer
        state.stepFrequency.lastStepFrequencyBuffer(1:stepConsts.stepFrequencyMaxNoOfSteps - 1) = state.stepFrequency.lastStepFrequencyBuffer(2:stepConsts.stepFrequencyMaxNoOfSteps);
        state.stepFrequency.lastStepFrequencyBuffer(stepConsts.stepFrequencyMaxNoOfSteps)       = stepFrequencyValue;
        
        state.stepFrequency.value   = sum(state.stepFrequency.lastStepFrequencyBuffer)/stepConsts.stepFrequencyMaxNoOfSteps;
    end
    state.stepFrequency.confidence  = state.stepFrequency.confidence - floor(abs(state.stepFrequency.value - state.stepFrequency.currentValue)/stepConsts.minFreqThresh);
    if state.stepFrequency.confidence < 0
        state.stepFrequency.confidence  = 0;
    end
    state.stepFrequency.lastTimeConfidenceUpdated   = state.sampleCount;
end
end


%---------------------------------------------------
% Function to Update Step Frequency for every sample
% Inputs
% -- State for step detection
% Outputs
% -- Updated state
%---------------------------------------------------
function state  = UpdateStepFrequency(state)

if (state.sampleCount - state.stepFrequency.lastTimeConfidenceUpdated) > stepConsts.stepFrequencyResetDuration
    state.stepFrequency.confidence  = max([0, state.stepFrequency.confidence - 1]);
    state.stepFrequency.lastTimeConfidenceUpdated   = state.sampleCount;
end
end
