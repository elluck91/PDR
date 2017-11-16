function [ z ] = emptyPosInfo()
%EMPTYPOSINFO to hold location related information, to set PDr location, 
%   please use memsPos struct

z = struct('Nsats',0, ... %U8, number of satellites to get fix
    'loc', emptyMemsPos, ...
    'speed_cm', emptySpeed, ...    %U16, Speed in cm/sec
    'bearing_degs', emptyHeading); %I16, heading from north in degs
end