function  memsState = memsLocHandler(memsState, data, timestamp)
%function to handle location information, we will call different function
%from here which need location like stide length cal, mag model update
if(memsState.logging.unitTestLogging.memsControl>-1)
    writeLine(memsState.logging.unitTestLogging.memsControl, createMsg(data,timestamp,memsIDs.locationHandler));
end

%to soon update
deltaTime = data.loc.utcTime - memsState.info.loc.current.loc.utcTime ;
notOk = data.loc.valid <=0 || data.loc.utcTime <= 0 || deltaTime < 100;
if(notOk)
    return;
end

%If time is around 500ms check error
if(deltaTime < 500)
    disterr = (memsState.info.loc.current.loc.posConf.major_cm^2 + memsState.info.loc.current.loc.posConf.minor_cm^2);
    if(disterr < (data.loc.posConf.major_cm^2 + data.loc.posConf.minor_cm^2))
        return;
    end
end

memsState.moduleState.IGRFmodel = setMagModelPositionTime(memsState.moduleState.IGRFmodel, data.loc, timestamp, memsState.logging);

memsState.info.loc.lastKnown =  memsState.info.loc.current;
memsState.info.loc.current = emptyPosInfo;
memsState.info.loc.current = data;
end