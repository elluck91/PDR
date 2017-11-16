function [needReset, configData ] = memsSetConfig(configData, data, timestamp, logging)
%MEMSCONFIG Summary of this function goes here
%   dunction to set configuration
if(nargin < 4)
    logging.unitTestLogging.memsConfig = -1;
end

if(logging.unitTestLogging.memsConfig>-1)
    writeLine(logging.unitTestLogging.memsConfig, createMsg(data,timestamp,memsIDs.memsConfig));
end

needReset = 0;
sensId =  zeros(1,4);

for n = 1:data.nSens
    switch(bitand(data.sensorInfo(n).type, memsConsts.SENSORTYPE_MASK))
        case memsConsts.sensAccType
            [isOk, configData.acc] = setSensorInfo(configData.acc,data.sensorInfo(n));
            sensId(1) = 1;
        case memsConsts.sensGyrType
            [isOk, configData.gyr] = setSensorInfo(configData.gyr,data.sensorInfo(n));
            sensId(2) = 1;
        case memsConsts.sensMagType
            [isOk, configData.mag] = setSensorInfo(configData.mag,data.sensorInfo(n));
            sensId(3) = 1;
        case memsConsts.sensPressureType
            [isOk, configData.pressure] = setSensorInfo(configData.pressure,data.sensorInfo(n));
            sensId(4) = 1;
    end
    if(~isOk)
        if(logging.verbose>=1)
            disp('memsSetConfig:Need Reset');
        end
        needReset = 1;
    end
end

%check how many sensor are already set earlier
nSens = checkTotalSensor(configData);
%only when new config is having less than previous set
if(sum(sensId) < nSens)
    needReset = 1;
    for n = 1:length(sensId)
        if(sensId(n)==0)
            switch n
                case memsConsts.sensAccType
                    configData.acc.info = emptySensorInfo;
                case memsConsts.sensGyrType
                    configData.gyr.info = emptySensorInfo;
                case memsConsts.sensMagType
                    configData.mag.info = emptySensorInfo;
                case memsConsts.sensPressureType
                    configData.press.info = emptySensorInfo;
                    
            end
        end
    end
end
end

%check if we set config earlier and different than the last one ?
function [isOk,sensInfo] = setSensorInfo(sensInfo, info)
isOk =  (sensInfo.info.type      ~= info.type || ...
    sensInfo.info.sample_ms  ~= info.sample_ms || ...
    sensInfo.info.SF         ~= info.SF);
if(~isOk)
    return;
else
    cal = sensInfo.cal;
    nAcq = round(dataBufferConsts.maxAcqBufferLength_ms/max(info.sample_ms,1));
    nProc = round(dataBufferConsts.maxProcBufferLength_ms/max(info.sample_ms,1));
    if(memsConsts.sensPressureType == info.type)
        nAxis = 1;
    else
        nAxis = 3;
    end
    sensInfo = emptyDataFrame(nAxis,nAcq,nProc);
    sensInfo.cal = cal;
    sensInfo.info = info;
end
end

function nL = checkTotalSensor(configData)
nL = 0;
if(configData.acc.info.type>0 && configData.acc.info.sample_ms>0 && configData.acc.info.SF>0)
    nL = nL+1;
end
if(configData.gyr.info.type>0 && configData.gyr.info.sample_ms>0 && configData.gyr.info.SF>0)
    nL = nL+1;
end
if(configData.mag.info.type>0 && configData.mag.info.sample_ms>0 && configData.mag.info.SF>0)
    nL = nL+1;
end
if(configData.pressure.info.type>0 && configData.pressure.info.sample_ms>0 && configData.pressure.info.SF>0)
    nL = nL+1;
end
end