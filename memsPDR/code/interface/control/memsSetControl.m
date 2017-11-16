function [ memsState, sensorRequired] = memsSetControl(memsState, data, timestamp )
%MEMSCONTROL Summary of this function goes here
%   function to set functionality requirement, this function will return
%   minumum sensors required to turn this functionality on.
%this function will allocate buffer appropriately or in memsInit. 
%//this function can be remove and mearge with init
if(memsState.logging.unitTestLogging.memsControl>-1)
    writeLine(memsState.logging.unitTestLogging.memsControl, createMsg(data,timestamp,memsIDs.memsControl));
end

sensorRequired = emptySensorRequire;
cntBit = data.controlMask;
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

%minimum sample rate require for acceleroemter to run all required fucntion
minSample_ms = getMinimumSample(cntBit);

nSens = 0;
if(attOn || accCalOn || magCalOn || stepOn || carryPosOn || contextOn  || staticDetectOn || altOn)
    nSens = nSens+1;
    sensorRequired.sensor(nSens).sensorId = memsConsts.sensAccType;
    sensorRequired.sensor(nSens).minSample_ms = minSample_ms*dataBufferConsts.nominalSamplePeriodAcc;
end

if(attOn || gyrCalOn)
    nSens = nSens+1;
    sensorRequired.sensor(nSens).sensorId = memsConsts.sensGyrType;
    sensorRequired.sensor(nSens).minSample_ms = minSample_ms*dataBufferConsts.nominalSamplePeriodGyr;
end

if(attOn || magCalOn)
    nSens = nSens+1;
    sensorRequired.sensor(nSens).sensorId = memsConsts.sensMagType;
    sensorRequired.sensor(nSens).minSample_ms = minSample_ms*dataBufferConsts.nominalSamplePeriodMag;
end

if(altOn)
    nSens = nSens+1;
    sensorRequired.sensor(nSens).sensorId = memsConsts.sensPressureType;
    sensorRequired.sensor(nSens).minSample_ms = minSample_ms*dataBufferConsts.nominalSamplePeriodPress;
end
sensorRequired.nMinSensors = nSens;
if(memsState.moduleState.pdrOutput.status == memsConsts.memsInitDisable)
    memsState.control.controlMask = data.controlMask;
elseif(memsState.logging.verbose>0)
    disp(['memsSetControl: Disable mems before setting new control @ time : ' num2str(timestamp)]);
end
end

%minimum sample rate to run all configured features.
function minSample_ms = getMinimumSample(data)
minSample_ms = 1000;

pdrOn = bitand(data,memsConsts.enablePDR)>0;
walkingAngleOn = bitand(data,memsConsts.enableWalkingAngle)>0;
strideLearningOn = bitand(data,memsConsts.enableStrideLengthLearning)>0;
attOn = bitand(data,memsConsts.enableAttitude)>0 || pdrOn || walkingAngleOn;
accCalOn = bitand(data,memsConsts.enableAccCal)>0;
gyrCalOn = bitand(data,memsConsts.enableGyroCal)>0 || attOn;
magCalOn = bitand(data,memsConsts.enableMagCal)>0 || attOn;
stepOn = bitand(data,memsConsts.enableStepDetection)>0 ||pdrOn ||strideLearningOn;
carryPosOn = bitand(data,memsConsts.enableCarryPos)>0 || pdrOn || walkingAngleOn;
contextOn = bitand(data,memsConsts.enablePDRContext)>0;
altOn = bitand(data,memsConsts.enableAltContext)>0;
staticDetectOn = bitand(data,memsConsts.enableStaticDetect)>0;

if(staticDetectOn)
    minSample_ms = min(minSample_ms, staticDetectConsts.minSample_ms);
end
if(altOn)
    minSample_ms = min(minSample_ms, altConsts.minSample_ms);
end
if(contextOn)
    minSample_ms = min(minSample_ms, contextConsts.minSample_ms);
end
if(stepOn)
    minSample_ms = min(minSample_ms, stepConsts.minSample_ms);
end
if (carryPosOn)
    minSample_ms = min(minSample_ms, carryPosConsts.minSample_ms);
end
if(magCalOn)
    minSample_ms = min(minSample_ms, magCalConsts.minSample_ms);
end
if(gyrCalOn)
    minSample_ms = min(minSample_ms, gyrCalConsts.minSample_ms);
end
if(accCalOn)
    minSample_ms = min(minSample_ms, accCalConsts.minSample_ms);
end
if(attOn)
    minSample_ms = min(minSample_ms, attConsts.minSample_ms);
end
if(walkingAngleOn)
    minSample_ms = min(minSample_ms, walkingAngleConsts.minSample_ms);
end
if(pdrOn)
    minSample_ms = min(minSample_ms, pdrOutputConsts.minSample_ms);
end
end