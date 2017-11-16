function [ z ] = emptyGTLoc()
%EMPTYMEMSPOS Summary of this function goes here
%   for initnial location 

z = struct('time', 0, ...   %U64,
    'latCir', 0, ...        %I32,Lat floor(degs*2^32/360)
    'lonCir', 0, ...        %I32.
    'alt_cm', 0, ...        %I32, alt in cm
    'UTC', 0);              %UTC in ms
end