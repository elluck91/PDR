function calInfo = memsGetCalInfo(memsState,sensorType,timestamp)
switch(sensorType)
    case memsConsts.sensMagId
        calInfo = memsState.data.mag.cal;
    case memsConsts.sensGyrId
        calInfo = memsState.data.gyr.cal;
    case memsConsts.sensAccId
        calInfo = memsState.data.acc.cal;
    case memsConsts.sensPressureId
        calInfo = memsState.data.pressure.cal;
    otherwise
        calInfo = emptyCalInfoOP(1);
end
end