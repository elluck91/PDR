function [ z ] = emptyCalInfoOP( nAxis )
%EMPTYCALINFO Summary of this function goes here
%   Dfunction to hold calibration value
z = struct('calStatus', memsConsts.calQStatusUnknown, ... U8
    'isDiagonal', 0, ... %bool
    'bias', zeros(nAxis,1), ... %float
    'SF', eye(nAxis,nAxis)); %float
end
%data = SF*(unCal-bias);