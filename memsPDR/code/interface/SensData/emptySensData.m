function [ z ] = emptySensData()
%EMPTYSENSDATA to pass input acq sensor data
z = struct('timestamp', memsConsts.INVALID, ... %U32,timestamp
    'nSens', 0, ...           %U8, number of sensor data in this message
    'data', emptyData);
end

function z = emptyData()
z = struct('type', 0, ...      %U8, sensor type
    'N', 0, ...                %U8, number of data sample
    'datablock', emptyDataBlock);
end

function z = emptyDataBlock()
z = struct('dt', 0, ...    %U16, delta time from timestamp
    'x', 0, ...            %I16, sensor data
    'y', 0, ...
    'z', 0);
end