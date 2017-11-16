function memsState = memsReset(memsState, data, timestamp, logging)
if(nargin < 4)
    logging.unitTestLogging.memsControl = -1;
end
if(logging.unitTestLogging.memsControl>-1)
    writeLine(logging.unitTestLogging.memsControl, createMsg(data,timestamp,memsIDs.memsReset));
end
if(logging.verbose>=1)
    disp(['mems Module Reset @ Time:-' num2str(timestamp)]);
end

cntBit = data.controlMask;
pdrReset = bitand(cntBit,memsConsts.enablePDR)>0;
walkingAngleReset = bitand(cntBit,memsConsts.enableWalkingAngle)>0;
strideLearningReset = bitand(cntBit,memsConsts.enableStrideLengthLearning)>0;
attReset = bitand(cntBit,memsConsts.enableAttitude)>0;
accCalReset = bitand(cntBit,memsConsts.enableAccCal)>0;
gyrCalReset = bitand(cntBit,memsConsts.enableGyroCal)>0;
magCalReset = bitand(cntBit,memsConsts.enableMagCal)>0;
stepReset = bitand(cntBit,memsConsts.enableStepDetection)>0;
contextReset = bitand(cntBit,memsConsts.enablePDRContext)>0;
altReset = bitand(cntBit,memsConsts.enableAltContext)>0;
staticDetectReset = bitand(cntBit,memsConsts.enableStaticDetect)>0;
carryPosReset = bitand(cntBit,memsConsts.enableCarryPos)>0;
 
if(pdrReset)
    schedule = memsState.moduleState.pdrOutput.schedule;
    memsState.moduleState.pdrOutput = emptyPdrOutput(0);
    memsState.moduleState.pdrOutput.schedule = schedule;
    if(logging.verbose>=1)
        disp('mems Module Reset:-pdrOutput');
    end
end

if(walkingAngleReset)
    schedule = memsState.moduleState.walkingAngle.schedule;
    memsState.moduleState.walkingAngle = emptyWalkingAngle(0);
    memsState.moduleState.walkingAngle.schedule = schedule;
    if(logging.verbose>=1)
        disp('mems Module Reset:-walkingAngle');
    end
end

if(attReset)
    schedule = memsState.moduleState.attitude.schedule;
    memsState.moduleState.attitude =  emptyAttitude(0);
    memsState.moduleState.attitude.schedule = schedule;
    if(logging.verbose>=1)
        disp('mems Module Reset:-Att');
    end
end

if(accCalReset)
    schedule = memsState.moduleState.accCal.schedule;
    memsState.moduleState.accCal = emptyAccCal(0);
    memsState.moduleState.accCal.schedule = schedule;
    if(logging.verbose>=1)
        disp('mems Module Reset:-AccCal');
    end
end

if(gyrCalReset)
    schedule = memsState.moduleState.gyrCal.schedule;
    memsState.moduleState.gyrCal =  emptyGyrCal(0);
    memsState.moduleState.gyrCal.schedule = schedule;
    if(logging.verbose>=1)
        disp('mems Module Reset:-GyrCal');
    end
end

if(magCalReset)
    schedule = memsState.moduleState.magCal.schedule;
    memsState.moduleState.magCal =  emptyMagCal(0);
    memsState.moduleState.magCal.schedule = schedule;
    if(logging.verbose>=1)
        disp('mems Module Reset:-MagCal');
    end
end

if(stepReset)
    schedule = memsState.moduleState.stepDetection.schedule;
    memsState.moduleState.stepDetection =  emptyStepDetection(0);
    memsState.moduleState.stepDetection.schedule = schedule;
    if(logging.verbose>=1)
        disp('mems Module Reset:-Step');
    end
end

if(altReset)
    schedule = memsState.moduleState.altitude.schedule;
    memsState.moduleState.altitude =  emptyAltitude(0);
    memsState.moduleState.altitude.schedule = schedule;
    if(logging.verbose>=1)
        disp('mems Module Reset:-Alt');
    end
end

if(contextReset)
    schedule = memsState.moduleState.context.schedule;
    memsState.moduleState.context =  emptyContext(0);
    memsState.moduleState.context.schedule = schedule;
    if(logging.verbose>=1)
        disp('mems Module Reset:-context');
    end
end

if(carryPosReset)
    schedule = memsState.moduleState.carryPos.schedule;
    memsState.moduleState.carryPos = emptyCarryPos(0);
    memsState.moduleState.carryPos.schedule = schedule;
    if(logging.verbose>=1)
        disp('mems Module Reset:-carryPos');
    end
end

end