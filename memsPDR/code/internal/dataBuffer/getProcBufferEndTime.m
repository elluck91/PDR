function endTime = getProcBufferEndTime(sensors, data)
endTime = 2^64-1;
%minimum becasue we dont want to run it when only first sensor data arrive,
%pick the least
% addding padding becasuse it is possible one sensor is little behind by
% one sample so we dont need to wait for next sample to come
if(bitand(2^(memsConsts.sensAccType-1), sensors))
    if(data.acc.procBuffer.N > 0)
        endTime = min(data.acc.procBuffer.t + data.acc.info.sample_ms-1, endTime);
    else
        endTime = 0; %this may not write iff we stop receiving one sensor data
        return;
    end
end
if(bitand(sensors, 2^(memsConsts.sensGyrType-1))>0)
    if(data.gyr.procBuffer.N > 0)
        endTime = min(data.gyr.procBuffer.t + data.gyr.info.sample_ms -1, endTime);
    else
        endTime = 0;
        return;
    end
end
if(bitand(sensors, 2^(memsConsts.sensMagType-1))>0 )
    if(data.mag.procBuffer.N > 0)
        endTime = min(data.mag.procBuffer.t + data.mag.info.sample_ms - 1,endTime);
    else
        endTime = 0;
        return;
    end
end
if(bitand(sensors, 2^(memsConsts.sensPressureType-1))>0)
    if(data.pressure.procBuffer.N > 0)
        endTime = min(data.pressure.procBuffer.t + data.pressure.info.sample_ms - 1,endTime);
    else
        endTime = 0;
        return;
    end
end
if(endTime ==2^64-1)
    endTime = 0;
end
end