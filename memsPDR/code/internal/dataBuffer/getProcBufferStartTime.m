function startTime = getProcBufferStartTime(sensors, data)
startTime = 0;
if(bitand(2^(memsConsts.sensAccType-1), sensors))
    if(data.acc.procBuffer.N > 0)
        startTime = max(data.acc.procBuffer.t - (data.acc.procBuffer.N-1)*data.acc.info.sample_ms, startTime);
    else
        startTime = 0;
        return;
    end
end
if(bitand(sensors, 2^(memsConsts.sensGyrType-1))>0)
    if(data.gyr.procBuffer.N > 0)
        startTime = max(data.gyr.procBuffer.t - (data.gyr.procBuffer.N-1)*data.gyr.info.sample_ms, startTime);
    else
        startTime = 0;
        return;
    end
end
if(bitand(sensors, 2^(memsConsts.sensMagType-1))>0 )
    if(data.mag.procBuffer.N > 0)
        startTime = max(data.mag.procBuffer.t - (data.mag.procBuffer.N-1)*data.mag.info.sample_ms,startTime);
    else
        startTime = 0;
        return;
    end
end
if(bitand(sensors, 2^(memsConsts.sensPressureType-1))>0)
    if(data.pressure.procBuffer.N > 0)
        startTime = max(data.pressure.procBuffer.t - (data.pressure.procBuffer.N-1)*data.pressure.info.sample_ms,startTime);
    else
        startTime = 0;
        return;
    end
end
end