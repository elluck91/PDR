function [ z ] = emptyPhoneInfo()
%EMPTYPHONEINFO to hold phone information

z = struct('modelName', [], ... %String,timestamp
    'deviceId', memsConsts.INVALID); %U32, device ID
end