function [ z ] = emptymemsInit()
%EMPTYMEMSINIT Summary of this function goes here
%   Detailed explanation goes here
z = struct('switch',memsConsts.INVALID); %U8 or bool, 0 - diable, 1- enable
end