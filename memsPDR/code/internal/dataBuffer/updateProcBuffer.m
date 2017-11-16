function dataBuff =  updateProcBuffer(dataBuff,timestamp,logging)
%this functino will put data in processing buffer after doing linear
%interpolation
if(nargin < 3)
    logging.unitTestLogging.dataBuffer = -1;
end

if(logging.unitTestLogging.dataBuffer>-1)
    writeAllSensorDataInLog(logging.unitTestLogging.dataBuffer, dataBuff, 4, ...
        [memsConsts.sensAccId, memsConsts.sensGyrId, memsConsts.sensMagId, memsConsts.sensPressureId], [1,1,1,1], 0); %log all data
    writeLine(logging.unitTestLogging.dataBuffer, createMsg(0,timestamp,memsUnitTestIDs.uUpdateProcBuffer));
end

dataBuff.acc = updateOneProcessBuffer(dataBuff.acc,3,logging);
dataBuff.gyr = updateOneProcessBuffer(dataBuff.gyr,3,logging);
dataBuff.mag = updateOneProcessBuffer(dataBuff.mag,3,logging);
dataBuff.pressure = updateOneProcessBuffer(dataBuff.pressure,1,logging);

if(logging.unitTestLogging.dataBuffer>-1)
    writeAllSensorDataInLog(logging.unitTestLogging.dataBuffer, dataBuff, 4, ...
        [memsConsts.sensAccId, memsConsts.sensGyrId, memsConsts.sensMagId, memsConsts.sensPressureId], [0,0,0,1], 1); %check only proc
end

end

function dataBuff = updateOneProcessBuffer(dataBuff,nAxis, logging)
if(dataBuff.acqBuffer.N == 0 || dataBuff.acqBuffer.Nmax == 0 || dataBuff.procBuffer.Nmax == 0)
    return;
end

sample = zeros(nAxis,1);

acqLastIndx =  dataBuff.acqBuffer.lastIndx;
if(dataBuff.acqBuffer.N == dataBuff.acqBuffer.Nmax)
    acqFirstIndx = mod(dataBuff.acqBuffer.lastIndx, dataBuff.acqBuffer.Nmax)+1;
else
    acqFirstIndx = 1;
end

if(dataBuff.procBuffer.N == 0)
    tLastProc = dataBuff.acqBuffer.t(acqFirstIndx) - dataBuff.info.sample_ms;
else
    tLastProc = dataBuff.procBuffer.t;
end

if(dataBuff.acqBuffer.t(acqLastIndx) - tLastProc > dataBufferConsts.maxTimediff2Reset)
    if(logging.verbose>=2)
        disp(['updateOneProcessBuffer : Resetting processing buffer at time:' num2str(dataBuff.acqBuffer.t(acqLastIndx))]);
    end
    dataBuff.procBuffer.N = 0;
    dataBuff.procBuffer.lastIndx = 0;
    %jump straight to near latest time
    tLastProc = dataBuff.acqBuffer.t(acqLastIndx) - dataBufferConsts.maxTimediff2Reset;
    dataBuff.procBuffer.t = tLastProc;
end

while(tLastProc < dataBuff.acqBuffer.t(acqLastIndx) - dataBuff.info.sample_ms)
    %removing equal sign will process data -1 of acq buffer
    nextSampleTime = tLastProc + dataBuff.info.sample_ms;
    valid = 0;
    for n = 1:dataBuff.acqBuffer.Nmax
        lwIndx = acqFirstIndx;
        upIndx = acqFirstIndx + 1;
        if(lwIndx > dataBuff.acqBuffer.Nmax) % not necessary condition, never hit
            lwIndx = mod(lwIndx-1, dataBuff.acqBuffer.Nmax)+1;
            upIndx = lwIndx+1;
        end
        if(upIndx > dataBuff.acqBuffer.Nmax)
            upIndx = mod(upIndx-1, dataBuff.acqBuffer.Nmax)+1;
        end
%         tUp = dataBuff.acqBuffer.t(upIndx);
%         tLow = dataBuff.acqBuffer.t(lwIndx);
        %this conditino should agree with while if tLastProc< then u should
        %use t(upIndx) >, if it is <= then use >= as well. e.g tLastProc =
        %160, t(acqLastIndx) = 180, this will not satistfy this if conditin
        %and will return some wrong lwIndx
        if((dataBuff.acqBuffer.t(lwIndx) <= nextSampleTime) && (dataBuff.acqBuffer.t(upIndx) > nextSampleTime))
            acqFirstIndx = lwIndx;% to fasten the processing
            break;
        end
        acqFirstIndx = acqFirstIndx+1;
        acqFirstIndx = mod(acqFirstIndx-1, dataBuff.acqBuffer.Nmax)+1;
    end
    
    dt = dataBuff.acqBuffer.t(upIndx)- dataBuff.acqBuffer.t(lwIndx);
    if(dt < dataBufferConsts.maxMissingDataLength*dataBuff.info.sample_ms && dt > 0)
        valid = 1;
        alpha = (nextSampleTime-dataBuff.acqBuffer.t(lwIndx))/dt;
        if(alpha>1)
            if(logging.verbose>=1)
                disp(['updateOneProcessBuffer : linear Interpolation alpha is high:' num2str(dataBuff.acqBuffer.t(acqLastIndx))]);
            end
            alpha = 1;
            if(~(dataBuff.acqBuffer.t(lwIndx) <= nextSampleTime && dataBuff.acqBuffer.t(upIndx) > nextSampleTime))
                break;
            end
        end
        sample(1) = (1-alpha)*dataBuff.acqBuffer.x(lwIndx) + alpha*dataBuff.acqBuffer.x(upIndx);
        if(nAxis==3)
            sample(2) = (1-alpha)*dataBuff.acqBuffer.y(lwIndx) + alpha*dataBuff.acqBuffer.y(upIndx);
            sample(3) = (1-alpha)*dataBuff.acqBuffer.z(lwIndx) + alpha*dataBuff.acqBuffer.z(upIndx);
        end
    end
    
    dataBuff.procBuffer.N = dataBuff.procBuffer.N + 1;
    dataBuff.procBuffer.N = min(dataBuff.procBuffer.N, dataBuff.procBuffer.Nmax);
    
    dataBuff.procBuffer.lastIndx = dataBuff.procBuffer.lastIndx+1;
    if(dataBuff.procBuffer.lastIndx>dataBuff.procBuffer.Nmax)
        dataBuff.procBuffer.lastIndx = 1;
    end
    indx = dataBuff.procBuffer.lastIndx;
    dataBuff.procBuffer.t = nextSampleTime;
    dataBuff.procBuffer.valid(indx) = valid;
    %apply calibration
    sample = dataBuff.cal.SF*(sample - dataBuff.cal.bias)*dataBuff.info.SF;  %should be in float
    dataBuff.procBuffer.x(indx) = sample(1);
    if(nAxis==3)
        dataBuff.procBuffer.y(indx) = sample(2);
        dataBuff.procBuffer.z(indx) = sample(3);
    end
    tLastProc = nextSampleTime;
end
%dbg
% if(nAxis==3)
%     close;
%     tRef = 2^64-1;
%     tRef = min(tRef, dataBuff.procBuffer.t - (dataBuff.procBuffer.N-1)* dataBuff.info.sample_ms);
%     dump.acc = dataBuff;
%     dump.gyr = dataBuff;
%     dump.mag = dataBuff;
%     plotProcSensorData('data',dump , 'sensorType',dataBuff.info.type)
%     hold all
%     plot(dataBuff.acqBuffer.t(1:dataBuff.acqBuffer.N)-tRef, dataBuff.acqBuffer.x(1:dataBuff.acqBuffer.N)*dataBuff.info.SF, '.-')
%     plot(dataBuff.acqBuffer.t(1:dataBuff.acqBuffer.N)-tRef, dataBuff.acqBuffer.y(1:dataBuff.acqBuffer.N)*dataBuff.info.SF, '.-')
%     plot(dataBuff.acqBuffer.t(1:dataBuff.acqBuffer.N)-tRef, dataBuff.acqBuffer.z(1:dataBuff.acqBuffer.N)*dataBuff.info.SF,'.-')
% end
end