function phoneInfo = memsSetPhoneInfo(phoneInfo, data, timestamp, logging)
%function to set phone information
if(nargin < 4)
    logging.unitTestLogging.memsControl = -1;
end
if(logging.unitTestLogging.memsControl>-1)
    writeLine(logging.unitTestLogging.memsControl, createMsg(data,timestamp,memsIDs.memsSetPhoneInfo));
end

if(data.deviceId==memsConsts.INVALID || isempty(data.modelName))
    return;
end
phoneInfo = data;
end