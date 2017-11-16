function state = memsSetUserInfo(state, data, timestamp, logging)
%function to set phone information
if(nargin < 4)
    logging.unitTestLogging.memsControl = -1;
end
if(logging.unitTestLogging.memsControl>-1)
    writeLine(logging.unitTestLogging.memsControl, createMsg(data,timestamp,memsIDs.memsSetUserInfo));
end

if(data.height_cm > 0 && data.weight_kg > 0 && data.age_year > 0)
    userInfo = data;
else
    return;
end
%shall we remove info.user ??
state.info.user = userInfo;
state.moduleState.strideLength.userInfo = userInfo;
end
