function [ z ] = emptyStepRes()
% emptyStep Summary of this function goes here
%   Detailed explanation goes here
z = struct( 'nSteps',        0,      ...
            'time',          [],     ...
            'stepFreq',      [],     ...  % Average of stable step frequencies for each step
            'stepFreqConf',  []);         % Min of confidence of step frequency for each step
end