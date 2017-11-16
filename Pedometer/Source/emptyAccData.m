function [ z ]  = emptyAccData()
%emptyAccData Summary of this function goes here
%   Detailed explanation goes here
z   = struct('N',       0, ....
             'x',       zeros(stepConsts.samplingRate, 1),  ...
             'y',       zeros(stepConsts.samplingRate, 1),  ...     % Average of stable step frequencies for each step
             'z',       zeros(stepConsts.samplingRate, 1),  ...
             'valid',   zeros(stepConsts.samplingRate, 1));         % Min of confidence of step frequency for each step
end

