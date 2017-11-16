function [ state ] = AutoCorr_freq( state )

% Calculate autocorrelation and identify peaks in pattern
autoCov         = xcov(state.normAccAutoCovWindow, state.normAccAutoCovWindow);
[peaks, signs]  = GetPeaks(autoCov(stepConsts.normAccAutoCovWinSize + 1:end), stepConsts.searchWindowForAutoCovPeak, autoCov(stepConsts.normAccAutoCovWinSize + 1)*stepConsts.centerPeakRatioForNextPeak);

currentEnergy   = sqrt(state.energyInNorm);
state.stepFreqIdentified    = stepConsts.FALSE;

% If peaks are idenfied
if ~isempty(peaks)
    possibleStepFreq    = [];
    possiblePeaks       = [];
    
    % If energy of system is less than the maximum limit of
    % energy on which model is build
    if currentEnergy < stepConsts.maxModelEnergy
        
        for j = 1:length(peaks)
            stepFreq    = stepConsts.minSample_ms/peaks(j)*2;
            if signs(j) == stepConsts.POSITIVE_PEAK && ...
                    stepFreq < stepConsts.maxModelStepFreq && ...   % step freq in the expected range
                    stepFreq > stepConsts.minModelStepFreq
                possibleStepFreq    = [possibleStepFreq; stepFreq];
                possiblePeaks       = [possiblePeaks; peaks(j)];
            end
        end
        if ~isempty(possibleStepFreq)
            currentEnergyBasedStepFreq = ...
                stepConsts.p1*currentEnergy^4 + stepConsts.p2*currentEnergy^3 + ...
                stepConsts.p3*currentEnergy^2 + stepConsts.p4*currentEnergy   + stepConsts.p5;
            [error, index]  = min(abs(currentEnergyBasedStepFreq * ones(length(possibleStepFreq), 1) - possibleStepFreq));
            if error < stepConsts.maxAllowedErrorFromModel
                state.stepFreqIdentified    = possibleStepFreq(index);
            else
                peakValues  = autoCov(possiblePeaks + stepConsts.normAccAutoCovWinSize);
                [~,index]   = max(peakValues);
                if abs(possibleStepFreq(index) - currentEnergyBasedStepFreq) < stepConsts.maxAllowedErrorFromAutoCovPeak
                    state.stepFreqIdentified    = possibleStepFreq(index);
                end
            end
        end
    else % currentEnergy >= stepConsts.maxModelEnergy
        
        for j = 1:length(peaks)
            stepFreq    = stepConsts.minSample_ms/peaks(j)*2;
            if signs(j) == stepConsts.POSITIVE_PEAK && ...
                    stepFreq > stepConsts.outOfModelMinStepFreq
                possibleStepFreq    = [possibleStepFreq; stepFreq];
                possiblePeaks       = [possiblePeaks; peaks(j)];
            end
        end
        if ~isempty(possibleStepFreq)
            peakValues  = autoCov(possiblePeaks+stepConsts.normAccAutoCovWinSize + 1);
            [~,index]   = max(peakValues);
            state.stepFreqIdentified    = possibleStepFreq(index);
            if (state.stepFreqIdentified) > stepConsts.outOfModelMaxStepFreq || ( state.stepFreqIdentified < stepConsts.outOfModelMinStepFreq)
                state.stepFreqIdentified    = stepConsts.FALSE;
            end
        end
    end
end

% If step frequency identified is non zero, depending on the
% frequency range select the suitable filter and reset walking
% started duration
if state.stepFreqIdentified ~= stepConsts.FALSE  % if step freq identified
    if state.stepFreqIdentified < stepConsts.maxFilterAStepFreq
        state.currentlySelectedFilter   = stepConsts.FILTER_A;
    elseif state.stepFreqIdentified < stepConsts.maxFilterBStepFreq
        state.currentlySelectedFilter   = stepConsts.FILTER_B;
    elseif state.stepFreqIdentified < stepConsts.maxFilterCStepFreq
        state.currentlySelectedFilter   = stepConsts.FILTER_C;
    else
        state.currentlySelectedFilter   = stepConsts.FILTER_D;
    end
    state.walkingStartedDuration        = 0;    % reset walking duration
end
end


%-------------------
% General Function to identify peaks in a signal
% Inputs
% -- signal
% -- win : window in which derivative is checked
% -- thresh: peak value should be below or above this thresh
% Outputs
% -- peak: list of peaks in the signal
% -- signs: signs of the peaks in the signal
%-------------------
function [peaks, signs] = GetPeaks(signal, win, thresh)

diffSignal  = diff(signal);
peaks       = []; 
signs       = [];

inZone      = 0;
zoneValue   = 0;

for i = win + 1:length(diffSignal)
    peakFound   = 0;
    if max(diffSignal(i - win:i - win/2)) < 0 && min(diffSignal(i - win/2 + 1:i)) > 0 && signal(i) < -thresh
        peakFound   = -1;
    end
    if min(diffSignal(i - win:i - win/2)) > 0 && max(diffSignal(i - win/2 + 1:i)) < 0 && signal(i) > thresh
        peakFound   = 1;
    end
    if peakFound ~= 0
        if inZone == 0
            peaks       = [peaks; i - win/2 + 1];
            signs       = [signs; peakFound];
            zoneValue   = signal(i - win/2);
        end
        inZone  = 1;
    else
        if abs(signal(i) - zoneValue) > stepConsts.minZoneDiffValue
            inZone  = 0;
        end
    end
end
end