function state = memsGyrCalNVM(state, data, timestamp, logging)
if(nargin < 4)
    logging.unitTestLogging.attitude = -1;
end

% if(logging.unitTestLogging.magCal>-1)
%     writeAllSensorDataInLog(logging.unitTestLogging.dataBuffer, memsStatedata, data.nSens, [data.data.type], [0,0,1,0], 0); %log acq data
%     writeLine(logging.unitTestLogging.dataBuffer, createMsg(data,timestamp,memsUnitTestIDs.uUpdateAcqBuffer));
% end

%check if this is to load or to save, we dont need to process
if(data.infoType ==1 || bitand(state.control.controlMask,memsConsts.enableAttitude)==0)
    return;
end

isOk = 1;
isOk = isOk & data.infoType==0;
%check the quality
isOk = isOk & data.calTime_s>0;
isOk = isOk & data.calInfo.calStatus ~= memsConsts.calQStatusUnknown;
isOk = isOk & data.calInfo.isDiagonal==1; %cant have non diagonal 

if(logging.verbose > 0)
    if(isOk)
        disp('Loading the GyrCal from NVM');
    else
        disp('Rejecting the GyrCal from NVM');
    end
end

if(isOk)
    state.moduleState.attitude.gbias = data.calInfo.bias*state.data.gyr.info.SF*memsConsts.degs2Rads; %in rps
	state.data.gyr = updateProcBufferWithCal(state.data.gyr, data.calInfo, logging);
end
end