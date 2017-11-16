function [ z ] = emptyMemsConfig()
%EMPTYMEMSCONFIG to configure each sensors
%
z = struct('nSens', 0, ...           %U8, number of sensor config in this
    'sensSrc', memsConsts.INVALID, ... %enum (0-unknown, 1 -Android,2-iOs,3-Native)
    'sensorInfo', emptySensorInfo);
end