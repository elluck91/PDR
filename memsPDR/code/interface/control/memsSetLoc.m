function memsState = memsSetLoc(memsState, data,timestamp)
%function to set initial location information
if(memsState.logging.unitTestLogging.memsControl>-1)
    writeLine(memsState.logging.unitTestLogging.memsControl, createMsg(data,timestamp,memsIDs.memsSetLoc));
end


%set only Mag model location, dont update loc.current,.. locationhander
%will cause issue. setMagModel should handle the validity
if ~checkPosValidity(data)
    return;
end
memsState.moduleState.IGRFmodel = setMagModelPositionTime(memsState.moduleState.IGRFmodel, data,timestamp, memsState.logging);
if(memsState.logging.verbose>=1)
    disp(['memsSetLoc:Position is set to Lat:' num2str(data.latCir*360/2^32) ', and Lon:' num2str(data.lonCir*360/2^32)]);
end
end

function valid = checkPosValidity(pos)
valid = 0;
if(pos.valid <=0 || pos.utcTime <= 0)
    return;
end
if(abs(pos.latCir)>2^30 || abs(pos.lonCir)>2^31)
    return;
end
valid = 1;
end