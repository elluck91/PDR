function state = memsMagCalNVM(state, data, timestamp, logging)
if(nargin < 4)
    logging.unitTestLogging.magCal = -1;
end

% if(logging.unitTestLogging.magCal>-1)
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
isOk = isOk & data.calHist.N > 0 & data.calHist.N <= data.calHist.Nmax;

if(logging.verbose > 0)
    if(isOk)
        disp('Loading the MagCal from NVM');
    else
        disp('Rejecting the MagCal from NVM');
    end
end
    
if(isOk)
    state.moduleState.magCal.calInfo = data.calInfo;
    state.moduleState.magCal.calTime_s = data.calTime_s;
    state.moduleState.magCal.calHist = data.calHist;
    %update the data buffer cal as well
    state.data.mag = updateProcBufferWithCal(state.data.mag, state.moduleState.magCal.calInfo, logging);
end
end