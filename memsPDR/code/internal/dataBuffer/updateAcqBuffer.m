function [ memsStatedata ] = updateAcqBuffer(memsStatedata,data, timestamp, logging)
%memsDataHandler Summary of this function goes here
%   function to handle acq sensor measurements, this will simply put in circular buffer 
if(nargin < 4)
    logging.unitTestLogging.dataBuffer = -1;
end

if(logging.unitTestLogging.dataBuffer>-1)
    writeAllSensorDataInLog(logging.unitTestLogging.dataBuffer, memsStatedata, data.nSens, [data.data.type], [0,0,1,0], 0); %log acq data
    writeLine(logging.unitTestLogging.dataBuffer, createMsg(data,timestamp,memsUnitTestIDs.uUpdateAcqBuffer));
end

refTime = data.timestamp;
for n = 1:data.nSens
    type = data.data(n).type;
    switch type
        case memsConsts.sensMagId
            memsStatedata.mag.acqBuffer = updateOneAcqBuffer(memsStatedata.mag.acqBuffer, data.data(n), refTime, 3, logging.verbose);
        case memsConsts.sensGyrId
            memsStatedata.gyr.acqBuffer = updateOneAcqBuffer(memsStatedata.gyr.acqBuffer, data.data(n), refTime,3, logging.verbose);
        case memsConsts.sensAccId
            memsStatedata.acc.acqBuffer = updateOneAcqBuffer(memsStatedata.acc.acqBuffer, data.data(n), refTime,3, logging.verbose);
        case memsConsts.sensPressureId
            memsStatedata.pressure.acqBuffer = updateOneAcqBuffer(memsStatedata.pressure.acqBuffer, data.data(n), refTime,1,logging.verbose);
        otherwise
            if(logging.verbose>=2)
                disp(['updateAcqBuffer:No sensor found for type:' num2str(type)]);
            end
            break;
    end
end
if(logging.unitTestLogging.dataBuffer>-1)
    writeAllSensorDataInLog(logging.unitTestLogging.dataBuffer, memsStatedata, data.nSens, [data.data.type], [0,0,1,0], 1); %log acq data
end
end

function acqBuff = updateOneAcqBuffer(acqBuff, newSample, refTime, nAxis, verbose)

if(acqBuff.Nmax==0)
    return;
end

if(acqBuff.N >0 && acqBuff.t(acqBuff.lastIndx) > refTime + dataBufferConsts.maxTimediff2Reset)
    acqBuff.N = 0;
    acqBuff.lastIndx = 0;
     if(verbose>=1)
        disp(['updateOneAcqBuffer : Resetting Acq buffer at time:' num2str(refTime)]);
    end
end

for n = 1:newSample.N
    %dont allow backward time
    if(acqBuff.N >0 && acqBuff.t(acqBuff.lastIndx) > refTime + newSample.datablock(n).dt)
        if(verbose>=2)
            disp(['updateOneAcqBuffer:time is going backward:' num2str(refTime)]);
        end
        continue;
    end
    acqBuff.N = acqBuff.N + 1;
    acqBuff.N = min(acqBuff.N, acqBuff.Nmax);
    
    acqBuff.lastIndx = acqBuff.lastIndx+1;
    if(acqBuff.lastIndx>acqBuff.Nmax)
        acqBuff.lastIndx = 1;
    end
    indx = acqBuff.lastIndx;
    acqBuff.t(indx) = refTime + newSample.datablock(n).dt;
    acqBuff.x(indx) = newSample.datablock(n).x;
    if(nAxis==3)
        acqBuff.y(indx) = newSample.datablock(n).y;
        acqBuff.z(indx) = newSample.datablock(n).z;
    end
end
end