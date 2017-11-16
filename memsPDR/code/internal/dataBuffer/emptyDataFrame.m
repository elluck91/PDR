function [ z ] = emptyDataFrame( nAxis, nAcqBuferLength, nProcBuferLength)
%EMPTYDATAFRAME Summary of this function goes here
%   Detailed explanation goes here
z = struct('info',emptySensorInfo, ...
    'cal', emptyCalInfoOP(nAxis), ...
    'acqBuffer', emptyAcqBuffer(nAxis, nAcqBuferLength), ...
    'procBuffer', emptyProcBuffer(nAxis, nProcBuferLength));
end