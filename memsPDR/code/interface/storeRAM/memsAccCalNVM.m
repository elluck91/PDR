function state = memsAccCalNVM(state, data, timestamp, logging)
if(nargin < 4)
    logging.unitTestLogging.accCal = -1;
end

% if(logging.unitTestLogging.accCal>-1)
%     writeAllSensorDataInLog(logging.unitTestLogging.dataBuffer, memsStatedata, data.nSens, [data.data.type], [0,0,1,0], 0); %log acq data
%     writeLine(logging.unitTestLogging.dataBuffer, createMsg(data,timestamp,memsUnitTestIDs.uUpdateAcqBuffer));
% end

%check if this is to load or to save, we dont need to process
if(data.infoType ==1)
    return;
end

isOk = 1;
isOk = isOk & data.infoType==0;
%check the quality
isOk = isOk & data.calTime_s > 0;
isOk = isOk & data.calInfo.calStatus ~= memsConsts.calQStatusUnknown;

if(logging.verbose > 0)
    if(isOk)
        disp('Loading the accCal from NVM');
    else
        disp('Rejecting the accCal from NVM');
    end
end
    
if(isOk)
    state.moduleState.accCal.calInfo = data.calInfo;
    state.moduleState.accCal.calTime_s = data.calTime_s;
     %update the data buffer cal as well
    state.data.acc = updateProcBufferWithCal(state.data.acc, state.moduleState.accCal.calInfo, logging);
end
end