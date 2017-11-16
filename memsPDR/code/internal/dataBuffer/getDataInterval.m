function interval = getDataInterval(schedule, data, verbose)
%function to get actual suitable data interval for given schedule
interval = emptyInterval;
dataStartTime = getProcBufferStartTime(schedule.sensors, data);
dataEndTime = getProcBufferEndTime(schedule.sensors, data);
%minimumLagAtStart_ms will make algo to run 1000-minimumLagAtStart_ms 
endTime = dataEndTime - schedule.border_ms - 0*dataBufferConsts.minimumLagAtStart_ms; % should subtract some value to adjust
%basic check
if(dataStartTime == 0 || dataEndTime ==0 || dataEndTime== 2^64-1 || dataStartTime == 2^64-1)
    if(verbose>=2)
        disp(['getDataInterval:Something went wrong' num2str(data.acc.t)]);
    end
    return;
end
%running first time
if(schedule.lastTime <= 0)
    startTime = dataStartTime + schedule.border_ms;
else
    startTime = schedule.lastTime;
end

%check if we are running behind and need to jump, one sample is Ok to pass
if(startTime < dataStartTime + schedule.border_ms)
    jumpTime = dataStartTime - startTime;
    startTime = dataStartTime;
    if(verbose >=2)
        disp(['getDataInterval:Running behind, jump the processing by ' num2str(jumpTime) ' ms at ' num2str(dataStartTime)]);
    end
end

interval.valid = 1;
interval.startTime = startTime;
interval.endTime = endTime;
interval.borderEndTime = dataEndTime;
end