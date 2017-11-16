function result = unitTestReplayer(varargin)
%main function to play back log file with variable inputs
%output will contain memsState which holds the algorithm state
%and results which is requested
%input format should be "Name in string", value

result = emptyUnitTestResults;
memsState = [];

logging = [];
memsControl = [];
memsConfig = [];

sensorRequired = emptySensorRequire;

topdir = './';
fname = 'ST_PDR_Log.txt';

lineN = 1;
for n = 1:2:nargin
    switch varargin{n}
        %to set log file name
        case 'fname'
            fname = varargin{n+1};
            %to set top dir where file is stores
        case 'topdir'
            topdir = varargin{n+1};
        case 'logging'
            logging = varargin{n+1};
            %to set initial state of mems
        case 'memsState'
            memsState = varargin{n+1};
        case 'memsControl'
            memsControl = varargin{n+1};
        case 'memsConfig'
            memsConfig = varargin{n+1};
        otherwise
            error(['unknown arg: ' varargin{n}])
    end
end

topdir = strtrim(topdir);
if(~exist(topdir,'dir'))
    error([topdir ' directory not found:exit']);
end

if (topdir(end) ~= '/' && topdir(end) ~= '\')
    topdir = [topdir '/'];
end

if(~exist([topdir fname],'file'))
    error([fname ' file not found:exit']);
end

if(isempty(logging))
    logging = defaultLogging;
    logging.verbose = 0;
end

if(isempty(memsControl))
    memsControl = defaultMemsControl;
end

%it will create main structure to hold all state and output
if(isempty(memsState))
    memsState = memsLoader();
end

memsState.logging = logging;
[memsState, sensorRequired]  = memsSetControl(memsState, memsControl , 0);

fileID = fopen([topdir fname],'r');

if(fileID==-1)
    error([fname ' file not able to open:exit']);
end

tline = fgetl(fileID);
while ischar(tline)
    [msg, Ok] = readLine(tline);
    if(~Ok)
        tline = fgetl(fileID);
        continue;
    end
    switch(msg.header.id)
        case memsIDs.memsSetPhoneInfo
            memsState.info.phone = memsSetPhoneInfo(memsState.info.phone, msg.data, msg.header.timestamp, memsState.logging);
        case memsIDs.memsSetLoc
            memsState = memsSetLoc(memsState, msg.data, msg.header.timestamp);
        case memsIDs.memsSetUserInfo
            memsState.info.user = memsSetUserInfo(memsState.info.user, msg.data, msg.header.timestamp, memsState.logging);
        case memsIDs.memsSetStrideCal
            memsState = memsSetStrideCal(memsState, msg.data, msg.header.timestamp, memsState.logging);
        case memsIDs.memsInit
            memsState = memsInit(memsState, msg.data, msg.header.timestamp, memsState.logging);
        case memsIDs.memsConfig
            [~, memsState.data] = memsSetConfig(memsState.data, msg.data, msg.header.timestamp, memsState.logging);
        case memsIDs.memsControl
            [memsState, sensorRequired]  = memsSetControl(memsState, msg.data, msg.header.timestamp);
        case memsIDs.memsReset
            memsState = memsReset(memsState, msg.data, msg.header.timestamp, memsState.logging);
        case memsIDs.memsSensData
            memsState.data = memsDataHandler(memsState.data, msg.data, msg.header.timestamp, memsState.logging);
            memsState = memsProcessing(memsState, msg.header.timestamp);
        case memsIDs.locationHandler
            memsState = memsLocHandler(memsState, msg.data, msg.header.timestamp);
            
        case memsUnitTestIDs.uUpdateAcqBuffer
            memsState.data = updateAcqBuffer(memsState.data, msg.data, msg.header.timestamp, memsState.logging);
            
        case memsUnitTestIDs.uUpdateProcBuffer
            memsState.data = updateProcBuffer(memsState.data, msg.header.timestamp, memsState.logging);
            
            
            %mag model, no need to check state because there is nothing,
            %only input is pos adnd only output will change
        case memsUnitTestIDs.uMagModel_setPosTime
            memsState.moduleState.IGRFmodel = setMagModelPositionTime(memsState.moduleState.IGRFmodel, msg.data, msg.header.timestamp, memsState.logging);
        case memsUnitTestIDs.uMagModel_getIGRFModel
            magField = msg.data;
        case memsUnitTestIDs.uMagModel_getIGRFModel_vldt
            magField = getIGRFModel(memsState.moduleState.IGRFmodel,memsState.logging);
            result.IGRFmodel = validateIGRFoutput(result.IGRFmodel, magField, msg.data, msg.header.id, lineN, 100);
            
        case memsUnitTestIDs.uMagCal_state
            memsState.moduleState.magCal = msg.data;
            memsState.moduleState.magCal = updateMagCal(memsState.moduleState.magCal, memsState.data, magField, memsState.logging);
            
        case memsUnitTestIDs.uMagCal_state_vldt
            result.magCal = validateMagCal(result.magCal, memsState.moduleState.magCal, msg.data, msg.header.id, lineN, 2);
            
        case memsUnitTestIDs.uAccCal_state
            memsState.moduleState.accCal = msg.data;
            memsState.moduleState.accCal = updateAccCal(memsState.moduleState.accCal, memsState.data, memsState.logging);
            
        case memsUnitTestIDs.uAccCal_state_vldt
            result.accCal = validateAccCal(result.accCal, memsState.moduleState.accCal, msg.data, msg.header.id, lineN, 2);
            
        case memsUnitTestIDs.uAttitude_updateAttitude
            result.attitude = validateAttKF(result.attitude, memsState.moduleState.attitude, msg.data, msg.header.id, lineN, 2);
            memsState.moduleState.attitude = msg.data;
            memsState.moduleState.attitude = updateAttitude(memsState.moduleState.attitude, memsState.data, magField, memsState.logging);
            
        case memsUnitTestIDs.uAttitude_getAttitude
            att = msg.data;
            
        case memsUnitTestIDs.uAlt_state
            result.altitude = validateAlt(result.altitude, memsState.moduleState.altitude, msg.data, msg.header.id, lineN, 2);
            memsState.moduleState.altitude = msg.data;
            memsState.moduleState.altitude = updateAlt(memsState.moduleState.altitude, memsState.data, steps, memsState.logging);
            
            
            %unit test ID to load data
        case memsUnitTestIDs.uDataAcc_info
            memsState.data.acc.info = msg.data;
        case memsUnitTestIDs.uDataAcc_cal
            memsState.data.acc.cal = msg.data;
        case memsUnitTestIDs.uDataAcc_acqBuffer
            memsState.data.acc.acqBuffer = msg.data;
        case memsUnitTestIDs.uDataAcc_procBuffer
            memsState.data.acc.procBuffer = msg.data;
            
        case memsUnitTestIDs.uDataGyr_info
            memsState.data.gyr.info = msg.data;
        case memsUnitTestIDs.uDataGyr_cal
            memsState.data.gyr.cal = msg.data;
        case memsUnitTestIDs.uDataGyr_acqBuffer
            memsState.data.gyr.acqBuffer = msg.data;
        case memsUnitTestIDs.uDataGyr_procBuffer
            memsState.data.gyr.procBuffer = msg.data;
            
        case memsUnitTestIDs.uDataMag_info
            memsState.data.mag.info = msg.data;
        case memsUnitTestIDs.uDataMag_cal
            memsState.data.mag.cal = msg.data;
        case memsUnitTestIDs.uDataMag_acqBuffer
            memsState.data.mag.acqBuffer = msg.data;
        case memsUnitTestIDs.uDataMag_procBuffer
            memsState.data.mag.procBuffer = msg.data;
            
        case memsUnitTestIDs.uDataPressure_info
            memsState.data.pressure.info = msg.data;
        case memsUnitTestIDs.uDataPressure_cal
            memsState.data.pressure.cal = msg.data;
        case memsUnitTestIDs.uDataPressure_acqBuffer
            memsState.data.pressure.acqBuffer = msg.data;
        case memsUnitTestIDs.uDataPressure_procBuffer
            memsState.data.pressure.procBuffer = msg.data;
            
            %to validate the results
        case memsUnitTestIDs.uDataAcc_info_vldt
            result.dataBuffer = validateInfo(result.dataBuffer, memsState.data.acc.info, msg.data, msg.header.id, lineN);
        case memsUnitTestIDs.uDataAcc_cal_vldt
            result.dataBuffer = validateCalInfo(result.dataBuffer, memsState.data.acc.cal, msg.data, msg.header.id, lineN, 1E-3);
        case memsUnitTestIDs.uDataAcc_acqBuffer_vldt
            result.dataBuffer = validateacqBuffer(result.dataBuffer, memsState.data.acc.acqBuffer, msg.data, msg.header.id, lineN, 1, 3);
        case memsUnitTestIDs.uDataAcc_procBuffer_vldt
            result.dataBuffer = validateprocBuffer(result.dataBuffer, memsState.data.acc.procBuffer, msg.data, msg.header.id, lineN, 1, 3);
            
        case memsUnitTestIDs.uDataGyr_info_vldt
            result.dataBuffer = validateInfo(result.dataBuffer, memsState.data.gyr.info, msg.data, msg.header.id, lineN);
        case memsUnitTestIDs.uDataGyr_cal_vldt
            result.dataBuffer = validateCalInfo(result.dataBuffer, memsState.data.gyr.cal, msg.data, msg.header.id, lineN, 1E-3);
        case memsUnitTestIDs.uDataGyr_acqBuffer_vldt
            result.dataBuffer = validateacqBuffer(result.dataBuffer, memsState.data.gyr.acqBuffer, msg.data, msg.header.id, lineN, 1, 3);
        case memsUnitTestIDs.uDataGyr_procBuffer_vldt
            result.dataBuffer = validateprocBuffer(result.dataBuffer, memsState.data.gyr.procBuffer, msg.data, msg.header.id, lineN, 1, 3);
            
        case memsUnitTestIDs.uDataMag_info_vldt
            result.dataBuffer = validateInfo(result.dataBuffer, memsState.data.mag.info, msg.data, msg.header.id, lineN);
        case memsUnitTestIDs.uDataMag_cal_vldt
            result.dataBuffer = validateCalInfo(result.dataBuffer, memsState.data.mag.cal, msg.data, msg.header.id, lineN, 1E-1);
        case memsUnitTestIDs.uDataMag_acqBuffer_vldt
            result.dataBuffer = validateacqBuffer(result.dataBuffer, memsState.data.mag.acqBuffer, msg.data, msg.header.id, lineN, 1, 3);
        case memsUnitTestIDs.uDataMag_procBuffer_vldt
            result.dataBuffer = validateprocBuffer(result.dataBuffer, memsState.data.mag.procBuffer, msg.data, msg.header.id, lineN, 1, 3);
            
        case memsUnitTestIDs.uDataPressure_info_vldt
            result.dataBuffer = validateInfo(result.dataBuffer, memsState.data.pressure.info, msg.data, msg.header.id, lineN, 1E-3);
        case memsUnitTestIDs.uDataPressure_cal_vldt
            result.dataBuffer = validateCalInfo(result.dataBuffer, memsState.data.pressure.cal, msg.data, msg.header.id, lineN);
        case memsUnitTestIDs.uDataPressure_acqBuffer_vldt
            result.dataBuffer = validateacqBuffer(result.dataBuffer, memsState.data.pressure.acqBuffer, msg.data, msg.header.id, lineN, 1,1);
        case memsUnitTestIDs.uDataPressure_procBuffer_vldt
            result.dataBuffer = validateprocBuffer(result.dataBuffer, memsState.data.pressure.procBuffer, msg.data, msg.header.id, lineN, 1, 1);
            
             %carry Position 
        case memsUnitTestIDs.uCarryPosition_state_before_update
            if memsState.moduleState.carryPos.currentSample == 0
                memsState.moduleState.carryPos = msg.data;
            end
            memsState.moduleState.carryPos = updateCarryPos(memsState.moduleState.carryPos, memsState.data, memsState.logging);
        case memsUnitTestIDs.uCarryPosition_state_after_update
            result.carryPos = validatecarryPos(result.carryPos, memsState.moduleState.carryPos, msg.data, msg.header.id, lineN);
    end
    
    tline = fgetl(fileID);
    lineN = lineN+1;
end
fclose(fileID);

end

function res = validateInfo(res, Statedata, data, msgID, lineN)
isEqual = ((Statedata.type == data.type) && (Statedata.isDataCal == data.isDataCal) && ...
    (Statedata.range == data.range) &&  (Statedata.sample_ms == data.sample_ms) && (Statedata.SF == data.SF));
res = updateResult(res, isEqual, msgID, lineN, 'validateInfo');
end

function res = validateCalInfo(res, Statedata, data, msgID, lineN, tolLevel)
isEqual = ((Statedata.calStatus == data.calStatus) && (Statedata.isDiagonal == data.isDiagonal) && ...
    sum(abs(Statedata.bias - data.bias)) < tolLevel &&  sum(abs(Statedata.SF == data.SF)) < tolLevel);
res = updateResult(res, isEqual, msgID, lineN, 'validateCalInfo');
end

function res = validateacqBuffer(res, Statedata, data, msgID, lineN, tolLevel, nAxis)
isEqual = ((Statedata.N == data.N) && (Statedata.lastIndx == data.lastIndx) && (Statedata.Nmax == data.Nmax));

for n = 1:Statedata.N
    if(~isEqual); break;end
    isEqual = isEqual && (Statedata.t(n) == data.t(n)) && sum(abs(Statedata.x(n) - data.x(n))) < tolLevel;
    if(nAxis==3)
        isEqual = isEqual && sum(abs(Statedata.y(n) - data.y(n))) < tolLevel && sum(abs(Statedata.z(n) - data.z(n))) < tolLevel;
    end
end
res = updateResult(res, isEqual, msgID, lineN, 'validateacqBuffer');
end

function res = validateprocBuffer(res, Statedata, data, msgID, lineN, tolLevel, nAxis)
isEqual = ((Statedata.N == data.N) && (Statedata.lastIndx == data.lastIndx) && ...
    (Statedata.Nmax == data.Nmax)) && (Statedata.t == data.t);

for n = 1:Statedata.N
    if(~isEqual); break;end
    isEqual = isEqual && (Statedata.valid(n) == data.valid(n)) && sum(abs(Statedata.x(n) - data.x(n))) < tolLevel;
    if(nAxis==3)
        isEqual = isEqual && sum(abs(Statedata.y(n) - data.y(n))) < tolLevel && sum(abs(Statedata.z(n) - data.z(n))) < tolLevel;
    end
end
res = updateResult(res, isEqual, msgID, lineN, 'validateprocBuffer');
end

function res = validateIGRFoutput(res, Statedata, data, msgID, lineN, tolLevel)
isEqual = (Statedata.valid== data.valid) && abs(Statedata.E_nT - data.E_nT) < tolLevel && ...
    abs(Statedata.N_nT - data.N_nT) < tolLevel && abs(Statedata.U_nT - data.U_nT) < tolLevel;
res = updateResult(res, isEqual, msgID, lineN, 'validateIGRFoutput');
end

function res = validateMagCal(res, stateData, data, msgID, lineN, tolLevel)
isEqual = stateData.calHist.N==data.calHist.N && stateData.calHist.Nmax==data.calHist.Nmax;

for n = 1:stateData.calHist.N
    isEqual = isEqual && stateData.calHist.data(n).t==data.calHist.data(n).t && ...
        abs(stateData.calHist.data(n).quality - data.calHist.data(n).quality) < tolLevel && ...
        abs(stateData.calHist.data(n).qualitySF -data.calHist.data(n).qualitySF) < tolLevel && ...
        abs(stateData.calHist.data(n).bias(1) - data.calHist.data(n).bias(1)) < tolLevel && ...
        abs(stateData.calHist.data(n).bias(2) - data.calHist.data(n).bias(2)) < tolLevel && ...
        abs(stateData.calHist.data(n).bias(3) - data.calHist.data(n).bias(3)) < tolLevel && ...
        abs(stateData.calHist.data(n).SF(1) - data.calHist.data(n).SF(1)) < 0.01*1000 && ...
        abs(stateData.calHist.data(n).SF(2) - data.calHist.data(n).SF(2)) < 0.01*1000 && ...
        abs(stateData.calHist.data(n).SF(3) - data.calHist.data(n).SF(3)) < 0.01*1000;
    if(~isEqual); break;end
end
res = updateResult(res, isEqual, msgID, lineN, 'validateMagCal:calHist');

isEqual = stateData.lastSolveTime_s==data.lastSolveTime_s && stateData.calTime_s==data.calTime_s && ...
    stateData.isUpdateFrmLastRun==data.isUpdateFrmLastRun && stateData.tAnomaly==data.tAnomaly;

res = updateResult(res, isEqual, msgID, lineN, 'validateMagCal:time');

isEqual = stateData.calInfo.isDiagonal == data.calInfo.isDiagonal && stateData.calInfo.calStatus == data.calInfo.calStatus && ...
    abs(stateData.calInfo.bias(1) - data.calInfo.bias(1)) < tolLevel && ...
    abs(stateData.calInfo.bias(2) - data.calInfo.bias(2)) < tolLevel && ...
    abs(stateData.calInfo.bias(3) - data.calInfo.bias(3)) < tolLevel && ...
    abs(stateData.calInfo.SF(1,1) - data.calInfo.SF(1,1)) < 0.01 && ...
    abs(stateData.calInfo.SF(2,2) - data.calInfo.SF(2,2)) < 0.01 && ...
    abs(stateData.calInfo.SF(3,3) - data.calInfo.SF(3,3)) < 0.01;

res = updateResult(res, isEqual, msgID, lineN, 'validateMagCal:calInfo');

%isEqual = isequaln(stateData.magBuffer, data.magBuffer);
isEqual = stateData.magBuffer.N == data.magBuffer.N && stateData.magBuffer.Nmax == data.magBuffer.Nmax && ...
    stateData.magBuffer.tRef == data.magBuffer.tRef && stateData.magBuffer.lastIndx == data.magBuffer.lastIndx && ...
    abs(data.magBuffer.lastMag(1) - data.magBuffer.lastMag(1)) < tolLevel && ...
    abs(data.magBuffer.lastMag(2) - data.magBuffer.lastMag(2)) < tolLevel && abs(data.magBuffer.lastMag(3) - data.magBuffer.lastMag(3)) < tolLevel && ...
    stateData.magBuffer.xUpIndx == data.magBuffer.xUpIndx && stateData.magBuffer.xLowIndx == data.magBuffer.xLowIndx && ...
    stateData.magBuffer.yUpIndx == data.magBuffer.yUpIndx && stateData.magBuffer.yLowIndx == data.magBuffer.yLowIndx && ...
    stateData.magBuffer.zUpIndx == data.magBuffer.zUpIndx && stateData.magBuffer.zLowIndx == data.magBuffer.zLowIndx;

for n = 1:data.magBuffer.Nmax
isEqual =  isEqual && stateData.magBuffer.data(n).dt==data.magBuffer.data(n).dt && ...
        abs(stateData.magBuffer.data(n).x - data.magBuffer.data(n).x) < tolLevel && ...
        abs(stateData.magBuffer.data(n).y -data.magBuffer.data(n).y) < tolLevel && ...
        abs(stateData.magBuffer.data(n).z - data.magBuffer.data(n).z) < tolLevel;
    if(~isEqual); break;end
end

res = updateResult(res, isEqual, msgID, lineN, 'validateMagCal:magBuffer');

isEqual = stateData.totalMagHist.N == data.totalMagHist.N && stateData.totalMagHist.Nmax == data.totalMagHist.Nmax && ...
    stateData.totalMagHist.lastIndx == data.totalMagHist.lastIndx;
for n = 1:data.totalMagHist.Nmax
    isEqual = isEqual && abs(stateData.totalMagHist.mT(n) - data.totalMagHist.mT(n)) < tolLevel*10;
    if(~isEqual); break;end
end
res = updateResult(res, isEqual, msgID, lineN, 'validateMagCal:TotalMagHist');
end

%Carry Position
function res = validatecarryPos(res, stateData, data, msgID, lineN)
isEqual = stateData.carryPositionRes.carryPosition == data.carryPositionRes.carryPosition && ...
          stateData.carryPositionRes.conf == data.carryPositionRes.conf && ...
          stateData.currentCarryPosition == data.currentCarryPosition && ...
          stateData.onDeskTimeMap == data.onDeskTimeMap && ...
          stateData.inHandTimeMap == data.inHandTimeMap && ...
          stateData.nearHeadTimeMap == data.nearHeadTimeMap && ...
          stateData.shirtPocketTimeMap == data.shirtPocketTimeMap && ...
          stateData.trouserPocketTimeMap == data.trouserPocketTimeMap && ...
          stateData.armSwingTimeMap == data.armSwingTimeMap && ...
          stateData.confidentState == data.confidentState;
      
res = updateResult(res, isEqual, msgID, lineN,'validateCarryPositionOutput');
end

function res = validateAttKF(res, stateData, data, msgID, lineN, tolLevel)
isEqual = isequaln(stateData.init, data.init);

isEqual = isEqual && stateData.knobs.modX   ==  data.knobs.modX && ...   
    stateData.knobs.gbias_mode == data.knobs.gbias_mode  && ...      
    stateData.knobs.stopActionFilter == data.knobs.stopActionFilter  && ...
    stateData.knobs.dynamic_accel_mode == data.knobs.dynamic_accel_mode && ...
    max(abs(stateData.knobs.sensorFlags - data.knobs.sensorFlags)) < 0.01  && ...    
    abs(stateData.knobs.gyro_time_constant  - data.knobs.gyro_time_constant) < 0.01 &&...
    abs(stateData.knobs.gbias_thresh  -  data.knobs.gbias_thresh) < 0.01 &&...      
    abs(stateData.knobs.gbias_mag_th_sc -    data.knobs.gbias_mag_th_sc) < 0.01 &&...   
    abs(stateData.knobs.gbias_acc_th_sc  -  data.knobs.gbias_acc_th_sc) < 0.01 &&...   
    abs(stateData.knobs.gbias_gyro_th_sc -  data.knobs.gbias_gyro_th_sc) < 0.01 &&...  
    abs(stateData.knobs.gbias_process -     data.knobs.gbias_process) < 0.01 &&...     
    abs(stateData.knobs.ATime -  data.knobs.ATime) < 0.01 &&...  
    abs(stateData.knobs.MTime -  data.knobs.MTime) < 0.01 &&...  
    abs(stateData.knobs.PTime  - data.knobs.PTime) < 0.01 &&...  
    abs(stateData.knobs.FrTime - data.knobs.FrTime) < 0.01;  
res = updateResult(res, isEqual, msgID, lineN, 'validateAttKF:knobs');

isEqual = max(max(abs(stateData.mergeAction.move_merge_table- data.mergeAction.move_merge_table))) < 0.01 && ...
    max(max(abs(stateData.mergeAction.acc_merge_table- data.mergeAction.acc_merge_table))) < 0.01 && ...
    (abs(stateData.mergeAction.dcomb_th- data.mergeAction.dcomb_th)) < 0.01 && ...
    (abs(stateData.mergeAction.dcombRatio- data.mergeAction.dcombRatio)) < 0.01 && ...
    (abs(stateData.mergeAction.daccRatio- data.mergeAction.daccRatio)) < 0.01 && ...
     (abs(stateData.mergeAction.dgyroRatio- data.mergeAction.dgyroRatio)) < 0.01;

 res = updateResult(res, isEqual, msgID, lineN, 'validateAttKF:mergeAction');

isEqual = stateData.att.t0 == data.att.t0 &&  stateData.att.dt == data.att.dt && ...
    stateData.att.N == data.att.N;
for n = 1: stateData.att.N
    deltaY = angleDiff(stateData.att.yaw(n)*0.01 , data.att.yaw(n)*0.01);
    deltaP = 0.5*angleDiff(2*stateData.att.pitch(n)*0.01, 2*data.att.pitch(n)*0.01);
    deltaR = angleDiff(stateData.att.roll(n)*0.01, data.att.roll(n)*0.01);
    isEqual = isEqual && stateData.att.valid(n) == data.att.valid(n) ...
        && abs(deltaY) < 0.50 ...
        && abs(deltaR) < 0.5 ...
        && abs(deltaP) < 0.5 ...
        && abs(stateData.att.yaw_conf(n) - data.att.yaw_conf(n)) < 20 ...
        && abs(stateData.att.roll_conf(n) - data.att.roll_conf(n)) < 20 ...
        && abs(stateData.att.pitch_conf(n) - data.att.pitch_conf(n)) < 20;
    if(isEqual==0)
        break
    end
end
res = updateResult(res, isEqual, msgID, lineN, 'validateAttKF:att');

isEqual = isequaln(stateData.gbiasState, data.gbiasState);
res = updateResult(res, isEqual, msgID, lineN, 'validateAttKF:gBiasState');

isEqual = stateData.KF.init == data.KF.init && ...
    max(abs(stateData.KF.x - data.KF.x)) < 0.1 && ...
    max(max(abs(stateData.KF.P - data.KF.P))) < 0.05 ;

res = updateResult(res, isEqual, msgID, lineN, 'validateAttKF:KF');

isEqual = max(abs(stateData.q_in - data.q_in)) < 0.01;
isEqual = isEqual && max(abs(stateData.gbias - data.gbias)) < 0.01;
isEqual = isEqual && stateData.lastRun == data.lastRun && stateData.count == data.count;
res = updateResult(res, isEqual, msgID, lineN, 'validateAttKF:q_gBias_lastRun');

end

function res = validateAlt(res, stateData, data, msgID, lineN, tolLevel)

%pBData check
isEqual = stateData.pbData.N   ==  data.pbData.N && ...   
    stateData.pbData.lastIndx   ==  data.pbData.lastIndx  && ... 
    stateData.pbData.Nmax   ==  data.pbData.Nmax && ...
    stateData.pbData.t   ==  data.pbData.t;

for n = 1:stateData.pbData.N
    if(~isEqual)
        break;
    end
    isEqual =  isEqual && stateData.pbData.valid(n)   ==  data.pbData.valid(n) && ...
        abs(stateData.pbData.x(n)- data.pbData.x(n)) < 2;
end
isEqual =  isEqual && abs(stateData.pbData.meanX   -  data.pbData.meanX) < tolLevel && ...
        abs(stateData.pbData.deltaMx  -  data.pbData.deltaMx) < tolLevel;
res = updateResult(res, isEqual, msgID, lineN, 'validateAlt:pbData');  

isEqual = stateData.hist.tRef   ==  data.hist.tRef && ...
    stateData.hist.N   ==  data.hist.N && ...   
    stateData.hist.Nmax   ==  data.hist.Nmax && ...
    stateData.hist.lastIndx   ==  data.hist.lastIndx;

for n = 1:stateData.hist.N
    if(~isEqual)
        break;
    end
    isEqual =  isEqual && stateData.hist.valid(n)   ==  data.hist.valid(n) && ...
        abs(stateData.hist.H_cm(n)   ==  data.hist.H_cm(n)) < tolLevel;
end
isEqual =  isEqual && abs(stateData.hist.filt1d.meanX   ==  data.hist.filt1d.meanX) < tolLevel && ...
        abs(stateData.hist.filt1d.deltaMx   ==  data.hist.filt1d.deltaMx) < tolLevel;
res = updateResult(res, isEqual, msgID, lineN, 'validateAlt:hist');  

isEqual = stateData.stanNoise_iir.tRef   ==  data.stanNoise_iir.tRef && ...
    abs(stateData.stanNoise_iir.cSigma   ==  data.stanNoise_iir.cSigma) < tolLevel;
res = updateResult(res, isEqual, msgID, lineN, 'validateAlt:sigma');  

isEqual = stateData.contextHist.N   ==  data.contextHist.N && ...   
    stateData.contextHist.Nmax   ==  data.contextHist.Nmax && ...
    stateData.contextHist.lastIndx   ==  data.contextHist.lastIndx;

for n = 1:stateData.contextHist.N
    if(~isEqual)
        break;
    end
    isEqual =  isEqual && stateData.contextHist.v(n)   ==  data.contextHist.v(n) && ...
        stateData.contextHist.context(n)   ==  data.contextHist.context(n) && ...
        abs(stateData.contextHist.slope(n)   ==  data.contextHist.slope(n)) < 0.1;
end
res = updateResult(res, isEqual, msgID, lineN, 'validateAlt:Contexthist');  

%res
isEqual = stateData.res.t   ==  data.res.t && ...   
    stateData.res.valid   ==  data.res.valid && ...
    abs(stateData.res.hBaro_cm -  data.res.hBaro_cm) < tolLevel && ...
    abs(stateData.res.hCal_cm -  data.res.hCal_cm) < tolLevel && ...
    abs(stateData.res.uVel.speed_cm -  data.res.uVel.speed_cm) <  tolLevel && ...
    abs(stateData.res.uVel.speed_conf -  data.res.uVel.speed_conf) < tolLevel && ...
stateData.res.context   ==  data.res.context && ...
abs(stateData.res.contextConf -  data.res.contextConf) < tolLevel;

res = updateResult(res, isEqual, msgID, lineN, 'validateAlt:res');  

end


function res = validateAccCal(res, stateData, data, msgID, lineN, tolLevel)
isEqual = stateData.lastSolveTime_s==data.lastSolveTime_s && stateData.calTime_s==data.calTime_s && ...
    stateData.isUpdateFrmLastRun==data.isUpdateFrmLastRun;

res = updateResult(res, isEqual, msgID, lineN, 'validateAccCal:time');

isEqual = stateData.calInfo.isDiagonal == data.calInfo.isDiagonal && stateData.calInfo.calStatus == data.calInfo.calStatus && ...
    abs(stateData.calInfo.bias(1) - data.calInfo.bias(1)) < tolLevel && ...
    abs(stateData.calInfo.bias(2) - data.calInfo.bias(2)) < tolLevel && ...
    abs(stateData.calInfo.bias(3) - data.calInfo.bias(3)) < tolLevel && ...
    abs(stateData.calInfo.SF(1,1) - data.calInfo.SF(1,1)) < 0.01 && ...
    abs(stateData.calInfo.SF(2,2) - data.calInfo.SF(2,2)) < 0.01 && ...
    abs(stateData.calInfo.SF(3,3) - data.calInfo.SF(3,3)) < 0.01;

res = updateResult(res, isEqual, msgID, lineN, 'validateAccCal:calInfo');

%isEqual = isequaln(stateData.accBuffer, data.accBuffer);
isEqual = stateData.accBuffer.N == data.accBuffer.N && stateData.accBuffer.Nmax == data.accBuffer.Nmax && ...
    stateData.accBuffer.tRef == data.accBuffer.tRef && stateData.accBuffer.lastIndx == data.accBuffer.lastIndx;

for n = 1:data.accBuffer.Nmax
isEqual =  isEqual && stateData.accBuffer.data(n).dt==data.accBuffer.data(n).dt && ...
        abs(stateData.accBuffer.data(n).x - data.accBuffer.data(n).x) < tolLevel && ...
        abs(stateData.accBuffer.data(n).y -data.accBuffer.data(n).y) < tolLevel && ...
        abs(stateData.accBuffer.data(n).z - data.accBuffer.data(n).z) < tolLevel;
    if(~isEqual); break;end
end

res = updateResult(res, isEqual, msgID, lineN, 'validateAccCal:accBuffer');
end

function res = updateResult(res, isEqual, msgID, lineN, functionName)
if(isEqual)
    res.Npass = res.Npass + 1;
else
    res.Nfail = res.Nfail + 1;
    disp(['UnitTest: Fail at ' num2str(lineN) 'Line number in function ' functionName ' and message id is ' num2str(msgID)]);
end
end