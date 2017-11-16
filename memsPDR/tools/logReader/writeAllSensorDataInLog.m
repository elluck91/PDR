function writeAllSensorDataInLog(fid, data, nSens, sensorType, mask, isValidation)
%generic function to write data structure in log file 
for n = 1:nSens
    switch sensorType(n)
        case memsConsts.sensAccId
            writeOneSensorDataInLog(fid,data.acc, memsConsts.sensAccId, mask, isValidation);
        case memsConsts.sensGyrId
            writeOneSensorDataInLog(fid,data.gyr, memsConsts.sensGyrId, mask, isValidation);
        case memsConsts.sensMagId
            writeOneSensorDataInLog(fid,data.mag, memsConsts.sensMagId, mask, isValidation);
        case memsConsts.sensPressureId
            writeOneSensorDataInLog(fid,data.pressure, memsConsts.sensPressureId, mask, isValidation);
    end
end
end