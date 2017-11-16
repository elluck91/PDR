function [ memsState ] = memsInit(memsState, data, timestamp, logging)
%MEMSINIT Summary of this function goes here
%   function to handle enable and disale message
if(nargin < 5)
    logging.unitTestLogging.memsControl = -1;
end
if(logging.unitTestLogging.memsControl>-1)
    writeLine(logging.unitTestLogging.memsControl, createMsg(data,timestamp,memsIDs.memsInit));
end
if(logging.verbose>=1)
    switch(data.switch)
        case 0
            disp('mems Module Disable');
        case 1
            disp('mems Module Enable');
    end
end

if(data.switch == memsState.moduleState.pdrOutput.status)
    if(logging.verbose>=1)
        disp(['memsInit:module is alreay Enable/disbale- ' num2str(data.switch)]);
    end
    return;
end
if(data.switch==0)
    %add the sequence before shutdown like setting state, saving NVM
    memsState.moduleState.pdrOutput.status = memsConsts.memsInitDisable;
    return;
end
%sens init
%reset everything
if(memsState.moduleState.pdrOutput.status == memsConsts.memsInitDisable)
    cntBit = memsState.control.controlMask;
    pdrOn = bitand(cntBit,memsConsts.enablePDR)>0;
    walkingAngleOn = bitand(cntBit,memsConsts.enableWalkingAngle)>0;
    strideLearningOn = bitand(cntBit,memsConsts.enableStrideLengthLearning)>0;
    attOn = bitand(cntBit,memsConsts.enableAttitude)>0 || pdrOn || walkingAngleOn;
    accCalOn = bitand(cntBit,memsConsts.enableAccCal)>0;
    gyrCalOn = bitand(cntBit,memsConsts.enableGyroCal)>0 || attOn;
    magCalOn = bitand(cntBit,memsConsts.enableMagCal)>0 || attOn;
    stepOn = bitand(cntBit,memsConsts.enableStepDetection)>0 || pdrOn || strideLearningOn;
    carryPosOn = bitand(cntBit,memsConsts.enableCarryPos)>0 || pdrOn || walkingAngleOn;
    contextOn = bitand(cntBit,memsConsts.enablePDRContext)>0;
    altOn = bitand(cntBit,memsConsts.enableAltContext)>0;
    staticDetectOn = bitand(cntBit,memsConsts.enableStaticDetect)>0;
    
    %make sure reserve bit remain on, compute reserve value, add all control
    %here
    reserveControl = 2^32-1;
    reserveControl = reserveControl - (memsConsts.enableAccCal + memsConsts.enableGyroCal + ...
        memsConsts.enableMagCal + memsConsts.enableStepDetection + memsConsts.enablePDRContext +  ...
        memsConsts.enableAltContext + memsConsts.enableStaticDetect + memsConsts.enableAttitude + ...
        memsConsts.enableWalkingAngle + memsConsts.enableStrideLengthLearning +  memsConsts.enablePDR);
    
    walkingAngleOn = isFunctionCompatible(walkingAngleConsts.minSensors, walkingAngleOn, memsState.data, walkingAngleConsts.minSample_ms);
    attOn = isFunctionCompatible(attConsts.minSensors, attOn, memsState.data, attConsts.minSample_ms);
    accCalOn = isFunctionCompatible(accCalConsts.minSensors, accCalOn, memsState.data, accCalConsts.minSample_ms);
    if(memsState.data.acc.info.isDataCal==1)
        if(memsState.logging.verbose>=1)
            disp('MEMS_INIT- Disabling acc Cal')
        end
        accCalOn = 0;
    end
    gyrCalOn = isFunctionCompatible(gyrCalConsts.minSensors, gyrCalOn, memsState.data, gyrCalConsts.minSample_ms);
    if(memsState.data.gyr.info.isDataCal==1)
        if(memsState.logging.verbose>=1)
            disp('MEMS_INIT- Disabling gyr Cal')
        end
        gyrCalOn = 0;
    end
    magCalOn = isFunctionCompatible(magCalConsts.minSensors, magCalOn,memsState.data, magCalConsts.minSample_ms);
    if(memsState.data.mag.info.isDataCal==1)
        if(memsState.logging.verbose>=1)
            disp('MEMS_INIT- Disabling mag Cal')
        end
        magCalOn = 0;
    end
    
    stepOn = isFunctionCompatible(stepConsts.minSensors, stepOn, memsState.data, stepConsts.minSample_ms);
    carryPosOn = isFunctionCompatible(carryPosConsts.minSensors, carryPosOn, memsState.data, carryPosConsts.minSample_ms);
    contextOn = isFunctionCompatible(contextConsts.minSensors, contextOn, memsState.data, contextConsts.minSample_ms);
    altOn = isFunctionCompatible(altConsts.minSensors, altOn, memsState.data, altConsts.minSample_ms);
    staticDetectOn = isFunctionCompatible(staticDetectConsts.minSensors, staticDetectOn, memsState.data, staticDetectConsts.minSample_ms);
    pdrOn = isFunctionCompatible(pdrOutputConsts.minSensors, pdrOn, memsState.data, pdrOutputConsts.minSample_ms);
        
    memsState.moduleState.accCal.schedule = setSchedule(memsState.moduleState.accCal.schedule,            ...
        accCalOn, accCalConsts.minSensors,                 ...
        accCalConsts.interval_ms, accCalConsts.border_ms);
    
    memsState.moduleState.gyrCal.schedule = setSchedule(memsState.moduleState.gyrCal.schedule,            ...
        gyrCalOn, gyrCalConsts.minSensors,                 ...
        gyrCalConsts.interval_ms, gyrCalConsts.border_ms);
    
    memsState.moduleState.magCal.schedule = setSchedule(memsState.moduleState.magCal.schedule,            ...
        magCalOn, magCalConsts.minSensors,                 ...
        magCalConsts.interval_ms, magCalConsts.border_ms);
    
    memsState.moduleState.context.schedule = setSchedule(memsState.moduleState.context.schedule,          ...
        contextOn, contextConsts.minSensors,                 ...
        contextConsts.interval_ms, contextConsts.border_ms);
    
    memsState.moduleState.attitude.schedule = setSchedule(memsState.moduleState.attitude.schedule,         ...
        attOn, attConsts.minSensors,                 ...
        attConsts.interval_ms, attConsts.border_ms);
    
    %special case
    memsState.moduleState.walkingAngle.walkAngleOn = walkingAngleOn>0;
    memsState.moduleState.walkingAngle.schedule = setSchedule(memsState.moduleState.walkingAngle.schedule, ...
        (pdrOn || walkingAngleOn), walkingAngleConsts.minSensors,                 ...
        walkingAngleConsts.interval_ms, walkingAngleConsts.border_ms);
    
    memsState.moduleState.stepDetection.schedule = setSchedule(memsState.moduleState.stepDetection.schedule,        ...
        stepOn, stepConsts.minSensors,                 ...
        stepConsts.interval_ms, stepConsts.border_ms);
    
    memsState.moduleState.carryPos.schedule = setSchedule(memsState.moduleState.carryPos.schedule,        ...
        carryPosOn, carryPosConsts.minSensors,                 ...
        carryPosConsts.interval_ms, carryPosConsts.border_ms);
    
    memsState.moduleState.altitude.schedule = setSchedule(memsState.moduleState.altitude.schedule,         ...
        altOn, altConsts.minSensors,                 ...
        altConsts.interval_ms, altConsts.border_ms);
    
    if(attOn || accCalOn || gyrCalOn || magCalOn || stepOn || carryPosOn || contextOn || staticDetectOn || altOn || walkingAngleOn)
        pdrOn = 1;
        minSensors = 2^(memsConsts.sensAccType-1);
        if(attOn || walkingAngleOn)
            minSensors = minSensors + 2^(memsConsts.sensGyrType-1) + 2^(memsConsts.sensMagType-1);
        else
            if(magCalOn)
                minSensors = minSensors  + 2^(memsConsts.sensMagType-1);
            end
            if(gyrCalOn)
                minSensors = minSensors  + 2^(memsConsts.sensGyrType-1);
            end
        end
        %causing issue
%         if(altOn)
%             minSensors = minSensors  + 2^(memsConsts.sensPressureType-1);
%         end
        memsState.moduleState.pdrOutput.schedule = setSchedule(memsState.moduleState.pdrOutput.schedule, ...
            pdrOn, minSensors, pdrOutputConsts.interval_ms, pdrOutputConsts.border_ms);
    end
    
    memsState.control.controlMask = accCalOn*memsConsts.enableAccCal + gyrCalOn*memsConsts.enableGyroCal + ...
        magCalOn*memsConsts.enableMagCal + stepOn*memsConsts.enableStepDetection + ...
        carryPosOn*memsConsts.enableCarryPos + contextOn*memsConsts.enablePDRContext + altOn*memsConsts.enableAltContext + ...
        staticDetectOn*memsConsts.enableStaticDetect + attOn*memsConsts.enableAttitude + ...
        walkingAngleOn*memsConsts.enableWalkingAngle + strideLearningOn*memsConsts.enableStrideLengthLearning + ...
        pdrOn*memsConsts.enablePDR + reserveControl;

    
    if(memsState.logging.verbose>=1)
        moduleControl = strvcat('--AccCal', '--GyroCal','--MagCal', ...
            '--StepDetection', '--CarryPosition', '--PDRContext', '--AltContext', ...
            '--Static', '--Attitude', '--walkingAngleOn', '--strideLearning', '--Pdr');
        onSwitch = [accCalOn , gyrCalOn , magCalOn , stepOn , carryPosOn , ...
            contextOn , altOn, staticDetectOn , attOn , ...
            walkingAngleOn , strideLearningOn, pdrOn];
        disp('memsControl: Submodule Enable:');
        disp(moduleControl(onSwitch>0, :));
    end
    
    memsState.data.mag.cal.calStatus = magCalConsts.initStatus;
    memsState.data.acc.cal.calStatus = accCalConsts.initStatus;
    memsState.data.gyr.cal.calStatus = memsConsts.calQStatusOk;
end
memsState.moduleState.pdrOutput.status = memsConsts.memsInitEnable;

%call the function to retrive NVM parameters
memsState = memsLoadMagCalNVM(memsState, memsState.logging);

memsState = memsLoadAccCalNVM(memsState, memsState.logging);

memsState = memsLoadGyrCalNVM(memsState, memsState.logging);
%define all default state here like calibration etc
end

function isOk = isFunctionCompatible(sensors, enabled, SensorConfig, minSample_ms)
isOk = 1;
if(~enabled)
    isOk = 0;
    return;
end

if (bitand(2^(memsConsts.sensAccType-1), sensors) > 0)
    if(SensorConfig.acc.info.sample_ms <= 0 || SensorConfig.acc.info.sample_ms > minSample_ms*dataBufferConsts.nominalSamplePeriodAcc)
        isOk = 0;
        return;
    end
end

if (bitand(2^(memsConsts.sensGyrType-1), sensors) > 0)
    if(SensorConfig.gyr.info.sample_ms <= 0 || SensorConfig.gyr.info.sample_ms > minSample_ms*dataBufferConsts.nominalSamplePeriodGyr)
        isOk = 0;
        return;
    end
end

if (bitand(2^(memsConsts.sensMagType-1), sensors) > 0)
    if(SensorConfig.mag.info.sample_ms <= 0 || SensorConfig.mag.info.sample_ms > minSample_ms*dataBufferConsts.nominalSamplePeriodMag)
        isOk = 0;
        return;
    end
end

if (bitand(2^(memsConsts.sensPressureType-1), sensors) > 0)
    if(SensorConfig.pressure.info.sample_ms <= 0 || SensorConfig.pressure.info.sample_ms > minSample_ms*dataBufferConsts.nominalSamplePeriodPress)
        isOk = 0;
        return;
    end
end
end

function schedule = setSchedule(schedule, enabled, sensors, interval_ms, border_ms)
schedule.enable =  enabled;
schedule.sensors = sensors;
schedule.interval_ms = interval_ms;
schedule.border_ms = border_ms;
end