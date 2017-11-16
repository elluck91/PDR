function writeOneSensorDataInLog(fid, data, sensorType, mask, isValidation)
% functino to write data buffer logging for specific sensor 
%input fid - file pointer
%data - data to be logged
% sensorType - which sensor
% mask - 4 mask first for info, 2nd for cal, 3 for acq/acq buffer and 4th for processing [1,1,1,1]
% isValidation is for assign data before processing or to check the results (1)
msgUID = zeros(1,4);
switch sensorType
    case memsConsts.sensAccId
        if(isValidation)
            msgUID = [memsUnitTestIDs.uDataAcc_info_vldt, memsUnitTestIDs.uDataAcc_cal_vldt, ...
                memsUnitTestIDs.uDataAcc_acqBuffer_vldt, memsUnitTestIDs.uDataAcc_procBuffer_vldt];
        else
            msgUID = [memsUnitTestIDs.uDataAcc_info,memsUnitTestIDs.uDataAcc_cal, ...
                memsUnitTestIDs.uDataAcc_acqBuffer,memsUnitTestIDs.uDataAcc_procBuffer];
        end
    case memsConsts.sensGyrId
        if(isValidation)
            msgUID = [memsUnitTestIDs.uDataGyr_info_vldt, memsUnitTestIDs.uDataGyr_cal_vldt, ...
                memsUnitTestIDs.uDataGyr_acqBuffer_vldt, memsUnitTestIDs.uDataGyr_procBuffer_vldt];
        else
            msgUID = [memsUnitTestIDs.uDataGyr_info, memsUnitTestIDs.uDataGyr_cal, ...
                memsUnitTestIDs.uDataGyr_acqBuffer, memsUnitTestIDs.uDataGyr_procBuffer];
        end
    case memsConsts.sensMagId
        if(isValidation)
            msgUID = [memsUnitTestIDs.uDataMag_info_vldt, memsUnitTestIDs.uDataMag_cal_vldt, ...
                memsUnitTestIDs.uDataMag_acqBuffer_vldt, memsUnitTestIDs.uDataMag_procBuffer_vldt];
        else
            msgUID = [memsUnitTestIDs.uDataMag_info, memsUnitTestIDs.uDataMag_cal, ...
                memsUnitTestIDs.uDataMag_acqBuffer, memsUnitTestIDs.uDataMag_procBuffer];
        end
    case memsConsts.sensPressureId
        if(isValidation)
            msgUID = [memsUnitTestIDs.uDataPressure_info_vldt, memsUnitTestIDs.uDataPressure_cal_vldt, ...
                memsUnitTestIDs.uDataPressure_acqBuffer_vldt, memsUnitTestIDs.uDataPressure_procBuffer_vldt];
        else
            msgUID = [memsUnitTestIDs.uDataPressure_info,memsUnitTestIDs.uDataPressure_cal, ...
                memsUnitTestIDs.uDataPressure_acqBuffer,memsUnitTestIDs.uDataPressure_procBuffer];
        end
end

if(mask(1))
    writeLine(fid,createMsg(data.info,0,msgUID(1)));
end
if(mask(2))
    writeLine(fid,createMsg(data.cal,0,msgUID(2)));
end
if(mask(3))
    writeLine(fid,createMsg(data.acqBuffer,0,msgUID(3)));
end
if(mask(4))
    writeLine(fid,createMsg(data.procBuffer,0,msgUID(4)));
end
end