function [ z ] = emptyProcBuffer( nAxis, nLength )
%EMPTYPROCBUFFER Summary of this function goes here
%   Detailed explanation goes here

if(nAxis==1)
    z = empty1DProcBuffer(nLength);
else
    z = empty3DProcBuffer(nLength);
end
end

function z = empty1DProcBuffer(nLength)
z = struct('N', 0, ...
    'lastIndx', 0, ...
    'Nmax', nLength, ...
    't',0, ...
    'valid', zeros(nLength,1), ...
    'x', single(zeros(nLength,1)));
end

function z = empty3DProcBuffer(nLength)
z = struct('N', 0, ...  %U16 or U8 is fine
    'lastIndx', 0, ...  %same as N
    'Nmax', nLength, ...%same as N
    't',0, ...          %U32
    'valid', zeros(nLength,1), ... %bool
    'x', single(zeros(nLength,1)), ... %float
    'y', single(zeros(nLength,1)), ...
    'z', single(zeros(nLength,1)));
end