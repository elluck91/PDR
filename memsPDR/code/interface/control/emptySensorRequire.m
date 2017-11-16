function [ z ] = emptySensorRequire()
%EMPTYSENSORREQUIRE Summary of this function goes here
%   structure to hld min sensor required info
z =  struct('nMinSensors', memsConsts.INVALID, ...
    'sensor', emptySensorSet);
end

function z = emptySensorSet
z = struct('sensorId',0, ...
    'minSample_ms',0);
end