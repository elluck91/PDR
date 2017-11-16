function isOk = checkTimeToRun(schedule, data, verbose)
isOk = 0;

if(~schedule.enable)
    if(verbose>=2)
        disp('CheckTimetoRun - module is disable')
    end
    return;
end
dataEndTime = getProcBufferEndTime(schedule.sensors, data);

if(dataEndTime < schedule.lastTime + schedule.interval_ms + schedule.border_ms)
    return;
end
dataStartTime = getProcBufferStartTime(schedule.sensors, data);
dataLength = dataEndTime - dataStartTime; %ideally we should add sample_ms because 
%this will measure inveral bw 2 sample and not the time since the start
%sufficinent data to process and dataLength suppose to be
%maxProcBufferLength_ms but if it more than that something went wrong. -
%remove this condition for variable datalength, 2*boarder if we hold in
%start and end
if(dataLength < schedule.interval_ms + schedule.border_ms || dataLength > 2*dataBufferConsts.maxProcBufferLength_ms)
    return;
else
    isOk = 1;
end
end