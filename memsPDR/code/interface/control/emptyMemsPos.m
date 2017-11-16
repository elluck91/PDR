function [ z ] = emptyMemsPos()
%EMPTYMEMSPOS Summary of this function goes here
%   for initnial location 

z = struct('valid', 0, ... %U8
    'utcTime', 0, ...      %U64, UTC in ms
    'latCir', 0, ...       %I32,Lat floor(degs*2^32/360)
    'lonCir', 0, ...       %I32.
    'alt_cm', 0, ...       %I32, alt in cm
    'posConf', emptyPosConf);
end