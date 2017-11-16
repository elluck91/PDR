function state = memsFactoryCal(state, data, timestamp, logging)

% if(logging.unitTestLogging.magCal>-1)
%     writeAllSensorDataInLog(logging.unitTestLogging.dataBuffer, memsStatedata, data.nSens, [data.data.type], [0,0,1,0], 0); %log acq data
%     writeLine(logging.unitTestLogging.dataBuffer, createMsg(data,timestamp,memsUnitTestIDs.uUpdateAcqBuffer));
% end

%check if this is to load or to save, we dont need to process

if(data.calInfo.calStatus ~= memsConsts.calQStatusUnknown)
    
    if(logging.verbose > 0)
        disp('Loading the Factory Cal');
    end
    
    switch data.sensType
        case memsConsts.sensMagId
            state.moduleState.magCal.calInfo = data.calInfo;
            %update the data buffer cal as well
            state.data.mag = updateProcBufferWithCal(state.data.mag, state.moduleState.magCal.calInfo, logging);
        case memsConsts.sensGyrId
            state.moduleState.gyrCal.calInfo = data.calInfo;
            %update the data buffer cal as well
            state.data.gyr = updateProcBufferWithCal(state.data.gyr, state.moduleState.gyrCal.calInfo, logging);
        case memsConsts.sensAccId
            state.moduleState.accCal.calInfo = data.calInfo;
            %update the data buffer cal as well
            state.data.acc = updateProcBufferWithCal(state.data.acc, state.moduleState.accCal.calInfo, logging);
        otherwise
            if(logging.verbose>=2)
                disp(['memsFactoryCal:No sensor found for FactoryCal:' num2str(type)]);
            end
    end
else
    disp('Rejecting the Factory Cal');
end
end