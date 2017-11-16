function [ z ] = emptyAcqBuffer(nAxis, nLength)
%EMPTYAcqBUFFER Summary of this function goes here
%   Detailed explanation goes here
if(nAxis==1)
    z = empty1DAcqBuffer(nLength);
else
    z = empty3DAcqBuffer(nLength);
end
end

function z = empty1DAcqBuffer(nLength)
z = struct('N', 0, ... %U16 or U32
    'lastIndx', 0, ... %same as N
    'Nmax', nLength, ...%same as N
    't', zeros(nLength,1), ... %U32
    'x', zeros(nLength,1)); %U16
end

function z = empty3DAcqBuffer(nLength)
z = struct('N', 0, ...
    'lastIndx', 0, ...
    'Nmax', nLength, ...
    't', zeros(nLength,1), ...
    'x', zeros(nLength,1), ...
    'y', zeros(nLength,1), ...
    'z', zeros(nLength,1));
end

% it is possible to maintain buffer in this format, for less complexity. If
% we are short of RAM we will adopt this format
% function z = empty3DAcqBuffer(nLength)
% z = struct('N', 0, ...
%     'lastIndx', 0, ...
%     'Nmax', nLength, ...
%     't0', 0, ... %starting time 
%     'dt', zeros(nLength,1), ...% delta time from t0 in U16 format
%     'x', zeros(nLength,1), ...
%     'y', zeros(nLength,1), ...
%     'z', zeros(nLength,1));
%this will same ram by U16*Nmax*number of sample but increase computation
%becasue whenever we update t0, we need to update dt
% end