function [msgData, Ok] = readLine(line,readOnlyMsgs)
%function to read one line message and convert into structure format
%this function is get called from readLog, all mesasges read function
%should be define in this, for write use writeLine file
if(nargin<2)
    readOnlyMsgs = [];
end
Ok = 0;
msgData = emptyMessage();
if(isempty(line) || length(line)<2)
    return;
end

data = sscanf(line, '%f,');

if(isempty(data) || length(data)<2)
    return;
end

checkId = data(1);

if(~isempty(readOnlyMsgs) && ~ismember(checkId,readOnlyMsgs))
    return;
end

%since memsConfig is having string
if(checkId == memsIDs.memsConfig)
    s = strsplit(line, ',');
    k = 5;
    for n = 1:data(3)
        data(k) = str2num(cell2mat(s(k))); k = k+1;
        data(k) = str2num(cell2mat(s(k))); k = k+1;
        data(k) = str2num(cell2mat(s(k))); k = k+1;
        data(k) = str2num(cell2mat(s(k))); k = k+1;
        data(k) = str2num(cell2mat(s(k))); k = k+1;
        data(k) = -1; k = k+1;
    end
elseif(checkId == memsIDs.memsSetPhoneInfo)
    s = strsplit(line, ',');
    data(3) = -1;
    data(4) = str2num(cell2mat(s(4)));
end

msgData.header.id = data(1);
msgData.header.timestamp = data(2);
try
    eval(sprintf('msgData.data = msgToStruct_%5d(data);', checkId));
    Ok = 1;
catch
    disp(['readLine:Skipping ' line ' line']);
    Ok = 0;
end
end

%%these function convert message to crresponding structure
%%you can add missing function here
%function to set phone info
function z = msgToStruct_10001(data)
z = emptyPhoneInfo;
k = 3;
z.modelName = data(k); k = k+1;
z.deviceId = data(k);
end

%function to set initial mems loc
function z = msgToStruct_10002(data)
z = emptyMemsPos;
k = 3;
z.valid = data(k); k = k+1;
z.utcTime = data(k); k = k+1;
z.latCir = data(k); k = k+1;
z.lonCir = data(k); k = k+1;
z.alt_cm = data(k); k = k+1;
z.posConf.major_cm = data(k); k = k+1;
z.posConf.minor_cm = data(k); k = k+1;
z.posConf.alt_cm = data(k); k = k+1;
z.posConf.ang_deg = data(k);
end

%function to set user info
function z = msgToStruct_10003(data)
z = emptyUserInfo;
k = 3;
z.height_cm = data(k); k = k+1;
z.weight_kg = data(k); k = k+1;
z.age_year = data(k); k = k+1;
z.gender = data(k);
end

%function to set stride length calibration info
function z = msgToStruct_10004(data)
z = emptyStrideCal;
k = 3;
z.refDist_cm = data(k); k = k+1;
z.Nsteps = data(k); k = k+1;
z.dT_s = data(k); k = k+1;
z.Context_Horiz = data(k); k= k+1;
z.posSource = data(k);
end

%function to control mems init enable or disable
function z = msgToStruct_10101(data)
z = emptymemsInit;
k = 3;
z.switch = data(k);
end

function z = msgToStruct_10102(data)
z = emptyMemsConfig;
k = 3;
z.nSens = data(k); k = k+1;
z.sensSrc = data(k); k = k+1;

for n = 1:z.nSens
    z.sensorInfo(n).type = data(k); k = k+1;
    z.sensorInfo(n).isDataCal = data(k); k = k+1;
    z.sensorInfo(n).range = data(k); k = k+1;
    z.sensorInfo(n).sample_ms = data(k); k = k+1;
    z.sensorInfo(n).SF = data(k); k = k+1;
    z.sensorInfo(n).vendorName = data(k); k = k+1;
end
end

function z =  msgToStruct_10103(data)
z = emptymemsControl;
k = 3;
z.controlMask = data(k);
end

function z =  msgToStruct_10104(data)
z = emptymemsControl;
k = 3;
z.controlMask = data(k);
end

function z = msgToStruct_10201(data)
z = emptySensData;

z.timestamp = data(3);
if(z.timestamp > 2^32-1) %UTC time 2013 
    z.timestamp = mod(z.timestamp, 2^32-1);
end
z.nSens = data(4);
k = 5;
for n = 1:z.nSens
    z.data(n).type = data(k); k = k+1;
    z.data(n).N = data(k); k = k+1;
    nDim = bitshift(bitand(z.data(n).type,memsConsts.AXIS_MASK),-6);
    for p = 1:z.data(n).N
        z.data(n).datablock(p).dt = data(k); k = k+1;
        z.data(n).datablock(p).x = data(k); k = k+1;
        if(nDim==3)
            z.data(n).datablock(p).y = data(k); k = k+1;
            z.data(n).datablock(p).z = data(k); k = k+1;
        end
    end
end
end

function z = msgToStruct_10202(data)
z = emptyPosInfo;
k = 3;
z.Nsats = data(k); k = k+1;
z.loc.valid = data(k); k = k+1;
z.loc.utcTime = data(k); k = k+1;
z.loc.latCir = data(k); k = k+1;
z.loc.lonCir = data(k); k = k+1;
z.loc.alt_cm = data(k); k = k+1;
z.loc.posConf.major_cm = data(k); k = k+1;
z.loc.posConf.minor_cm = data(k); k = k+1;
z.loc.posConf.alt_cm = data(k); k = k+1;
z.loc.posConf.ang_deg = data(k); k = k+1;
z.speed_cm.val = data(k); k = k+1;
z.speed_cm.conf = data(k); k = k+1;
z.bearing_degs.val = data(k); k = k+1;
z.bearing_degs.conf = data(k);
end

%need correction, TODO
function z = msgToStruct_10250(data)
k = 3;
z = emptyCalInfoOP(3);
z.sensType = data(k); k = k+1;
z.calInfo = msgToStruct_cal(data(k:k+ 2 + 3 + 3*3-1), 3);
end

function z = msgToStruct_10251(data)
z = emptyAccCalNVM;
k = 3;
z.infoType = data(k); k = k+1;
z.calTime_s = data(k); k = k+1;
z.calInfo = msgToStruct_cal(data(k:k+ 2 + 3 + 3*3-1), 3);
end


function z = msgToStruct_10252(data)
z = emptyGyrCalNVM;
k = 3;
z.infoType = data(k); k = k+1;
z.calTime_s = data(k); k = k+1;
z.calInfo = msgToStruct_cal(data(k:k+ 2 + 3 + 3*3-1), 3);
end

function z = msgToStruct_10253(data)
z = emptyMagCalNVM;
k = 3;
z.infoType = data(k); k = k+1;
z.calTime_s = data(k); k = k+1;
z.calInfo = msgToStruct_cal(data(k:k+ 2 + 3 + 3*3-1), 3); k = k+ 2 + 3 + 3*3;
z.calHist.N = data(k); k = k+1;
z.calHist.Nmax = data(k); k = k+1;
for n = 1:z.calHist.N
    z.calHist.data(n).t = data(k); k = k+1;
    z.calHist.data(n).quality = data(k); k = k+1;
    z.calHist.data(n).qualitySF = data(k); k = k+1;
    z.calHist.data(n).bias(1) = data(k); k = k+1;
    z.calHist.data(n).bias(2) = data(k); k = k+1;
    z.calHist.data(n).bias(3) = data(k); k = k+1;
    z.calHist.data(n).SF(1) = data(k); k = k+1;
    z.calHist.data(n).SF(2) = data(k); k = k+1;
    z.calHist.data(n).SF(3) = data(k); k = k+1;
    z.calHist.data(n).SFI(1) = data(k); k = k+1;
    z.calHist.data(n).SFI(2) = data(k); k = k+1;
    z.calHist.data(n).SFI(3) = data(k); k = k+1;
end
end

function z = msgToStruct_10005(data)
z = emptyAttKnobs;
k = 3;
z.modX = data(k);  k = k+1;
z.gbias_mode = data(k); k = k+1;
z.stopActionFilter = data(k); k = k+1;
z.dynamic_accel_mode = data(k); k = k+1;
z.sensorFlags(1) = data(k); k = k+1;
z.sensorFlags(2) = data(k); k = k+1;
z.sensorFlags(3) = data(k); k = k+1;
z.gyro_time_constant = data(k); k = k+1;
z.gbias_thresh = data(k); k = k+1;
z.gbias_mag_th_sc = data(k); k = k+1;
z.gbias_acc_th_sc = data(k); k = k+1;
z.gbias_gyro_th_sc = data(k); k = k+1;
z.ATime = data(k); k = k+1;
z.MTime = data(k); k = k+1;
z.PTime = data(k); k = k+1;
z.FrTime = data(k);
end


%For Carry Position message ID 10715 and 10716
function z = msgToStruct_10715(data)
    z = msgToStruct_carryPositionState(data);
end

function z = msgToStruct_10716(data)
    z = msgToStruct_carryPositionState(data);
end

function z = msgToStruct_carryPositionState(data)
z = emptyCarryPos;
z.schedule = msgToStruct_schedule(data(3:7));
k=8;
z.carryPositionRes.carryPosition = data(k);k=k+1;
z.carryPositionRes.conf = data(k);k=k+1;
z.currentSample = data(k);k=k+1;
z.sinceLastUpdate = data(k); k=k+1;
z.currentCarryPosition = data(k);k=k+1;
z.latestSampleLocation = data(k);k=k+1;
z.filterBufferLocation = data(k);k=k+1;
for i=1:length(z.filterX)
 z.filterX(i) = data(k);k=k+1; 
 end
for i=1:length(z.filter1Y)
 z.filter1Y(i) = data(k);k=k+1; 
end
for i=1:length(z.filter2Y)
  z.filter2Y(i) = data(k);k=k+1; 
end
for i=1:length(z.filter3Y)
  z.filter3Y(i) = data(k);k=k+1; 
end
for i=1:length(z.filter4Y)
 z.filter4Y(i) = data(k);k=k+1; 
end
for i=1:length(z.filter5Y)
 z.filter5Y(i) = data(k);k=k+1; 
end
z.onDeskTimeMap = data(k);k=k+1;
z.inHandTimeMap = data(k);k=k+1;
z.nearHeadTimeMap = data(k);k=k+1;
z.shirtPocketTimeMap = data(k);k=k+1;
z.trouserPocketTimeMap = data(k);k=k+1;
z.armSwingTimeMap = data(k);k=k+1;
z.confidentState = data(k);
end

%request messages
%tag
function z = msgToStruct_10402(data)
z  = [];
end

%step
function z = msgToStruct_10403(data)
z  = [];
end

%stride
function z = msgToStruct_10404(data)
z  = [];
end

%speed
function z = msgToStruct_10405(data)
z  = [];
end

%bodyPos
function z = msgToStruct_10410(data)
z  = [];
end

%userHeading
function z = msgToStruct_10411(data)
z  = [];
end

function z = msgToStruct_10501(data)
z = emptyGTLoc;
if(length(data)==6)
    k = 2;
elseif(length(data)==7)
    k = 3;
end
z.time = data(k); k = k+1;
z.latCir = data(k); k = k+1;
z.lonCir = data(k); k = k+1;
z.alt_cm = data(k); k = k+1;
z.UTC = data(k);
end

function z = msgToStruct_10502(data)
z = emptyGTYPR;
k = 3;
z.time  = data(k); k = k+1;
z.dt = data(k); k = k+1;
z.N = data(k); k = k+1;
for n = 1:z.N
    z.yaw_mdeg(n) = data(k); k = k+1;
    z.pitch_mdeg(n) = data(k); k = k+1;
    z.roll_mdeg(n) = data(k); k = k+1;
end
end

function z = msgToStruct_10503(data)
z = [];
end

function z = msgToStruct_10504(data)
z  = emptyGTContext;
k = 2;
z.time = data(k); k = k+1;
z.context = data(k); 
end

function z = msgToStruct_10505(data)
z  = emptyStepOP;
k = 2;
z.tLastStep = data(k); k = k+1;
z.stepCount = data(k);
z.step_conf = 0;
end

function z = msgToStruct_10506(data)
z  = emptyGTDist;
k = 2;
z.time = data(k); k = k+1;
z.dist_m = data(k); 
end

function z = msgToStruct_10508(data)
z  = emptyGTCarryPos;
k = 2;
z.time = data(k); k = k+1;
z.carryPos = data(k); 
end

function z = msgToStruct_10708(data)
z = [];
end

%update acqBuff
function z = msgToStruct_10709(data)
z = msgToStruct_10201(data);
end

function z = msgToStruct_10711(data)
z = msgToStruct_10002(data);
end

function z = msgToStruct_10712(data)
z = emptyMagField;
k = 3;
z.valid = data(k); k = k+1;
z.E_nT = data(k); k = k+1;
z.N_nT = data(k); k = k+1;
z.U_nT = data(k);
end

function data = msgToStruct_10713(z)
data = msgToStruct_10712(z);
end

function z = msgToStruct_10721(data) %att
z = emptyAttitude;
z.schedule = msgToStruct_schedule(data(3:7)); k = 8;
z.init.filter = data(k); k = k+1;
z.init.gbias = data(k); k = k+1;
z.init.sp_resetCntr = data(k); k = k+1;
z.knobs = msgToStruct_10005(data(k:k+15)); k = k+16;

z.att.t0 = data(k); k = k+1;
z.att.dt = data(k); k = k+1;
z.att.N = data(k); k = k+1;
for n = 1:z.att.N
    z.att.valid(n) = data(k); k = k+1;
    z.att.yaw(n) = data(k); k = k+1;
    z.att.roll(n) = data(k); k = k+1;
    z.att.pitch(n) = data(k); k = k+1;
    z.att.yaw_conf(n) = data(k); k = k+1;
    z.att.roll_conf(n) = data(k); k = k+1;
    z.att.pitch_conf(n) = data(k); k = k+1;
end

z.mergeAction = msgToStruct_AttMergeAction(data(k:k+55)); k = k+56;

z.gbiasState.wait = data(k); k = k+1;
z.gbiasState.wait2 = data(k); k = k+1;
z.gbiasState.wait3 = data(k); k = k+1;
z.gbiasState.gbiascnt = data(k); k = k+1;
z.gbiasState.gbias_mode_change = data(k); k = k+1;
z.gbiasState.Preset = data(k); k = k+1;
z.gbiasState.gval = data(k); k = k+1;

z.KF.init = data(k); k = k+1;
for n = 1:attConsts.NState
    z.KF.x(n) = data(k); k = k + 1;
end
%storing only upper portion
for n = 1:attConsts.NState
    for m = 1:n
        z.KF.P(n,m) = data(k); k = k+1;
        z.KF.P(m,n) = z.KF.P(n,m);
    end
end

histBuffSize = 1 + 9 + attConsts.kf_gbufsize*3 + 3 + 3*(3+ 3*attConsts.kf_dbufsize) + 2+ attConsts.kf_diffBufSize; 
z.histbuff =  msgToStruct_AttHistbuff(data(k:k+histBuffSize-1),z.histbuff); 
k = k + histBuffSize;

for n = 1:4
    z.q_in(n) = data(k); k = k+1;
end
for n = 1:3
    z.gbias(n) = data(k); k = k+1;
end
z.count = data(k); k = k+1;
z.lastRun = data(k);
end

function z = msgToStruct_AttMergeAction(data)
k = 1;
z = emptyActionFilter;
z.move_merge_table(1,1:13)= data(k:k+12); k = k+13;
z.move_merge_table(2,1:13)= data(k:k+12); k = k+13;
z.acc_merge_table(1,1:13)= data(k:k+12); k = k+13;
z.acc_merge_table(2,1:13)= data(k:k+12); k = k+13;
z.dcomb_th = data(k); k = k+1;
z.dcombRatio = data(k); k = k+1;
z.daccRatio = data(k); k = k+1;
z.dgyroRatio = data(k);
end

function z = msgToStruct_AttHistbuff(data, z)
k = 1;
z.init = data(k); k = k+1;
z.Tprev(1,:) = data(k:k+2); k = k+3;
z.Tprev(2,:) = data(k:k+2); k = k+3;
z.Tprev(3,:) = data(k:k+2); k = k+3;

z.propabs_buf = msgToStruct_AttVector(data(k:k+3+ 3*attConsts.kf_gbufsize-1),3, z.propabs_buf); k = k+3+ 3*attConsts.kf_gbufsize;
z.mag_buf = msgToStruct_AttVector(data(k:k+3+ 3*attConsts.kf_dbufsize-1), 3,  z.mag_buf); k = k+3+ 3*attConsts.kf_dbufsize;
z.acc_buf = msgToStruct_AttVector(data(k:k+3+ 3*attConsts.kf_dbufsize-1), 3, z.acc_buf); k = k+3+ 3*attConsts.kf_dbufsize;
z.gyro_buf = msgToStruct_AttVector(data(k:k+3+ 3*attConsts.kf_dbufsize-1), 3, z.gyro_buf); k = k+3+ 3*attConsts.kf_dbufsize;

z.slopFilterData.init = data(k); k = k+1;
% z.slopFilterData.halffiltCoeff; doesnt need to read or write, it is
% having default value
z.slopFilterData.Nmax = data(k); k = k+1;
for n = 1:attConsts.kf_diffBufSize
    z.slopFilterData.data(1,n) = data(k); k = k+1;
end
end

function z = msgToStruct_AttVector(data, nAxis, z)
k = 1;
z.N = data(k); k = k+1;
z.Nmax = data(k); k = k+1;
z.scale = data(k); k = k+1;
for n = 1:z.Nmax
    z.data(1,n) = data(k); k = k+1;
    if(nAxis>1)
        z.data(2,n) = data(k); k = k+1;
    end
    if(nAxis>2)
        z.data(3,n) = data(k); k = k+1;
    end
end
end

function z = msgToStruct_10722(data) %att requ
z = emptyOrientationOP; k = 1;
z.t0 = data(k); k = k+1;
z.N = data(k); k = k+1;
z.valid = data(k); k = k+1;
z.dt_ms = data(k); k = k+1;

for n = 1:z.N
    z.yaw(n) = data(k); k = k+1;
    z.roll(n) = data(k); k = k+1;
    z.pitch(n) = data(k); k = k+1;
end
z.yaw_conf = data(k); k = k+1;
z.roll_conf = data(k); k = k+1;
z.pitch_conf = data(k);
end

function z = msgToStruct_10723(data) %att
z = msgToStruct_10722(data); %att
end

%mag cal state
function z = msgToStruct_10730(data)
z = emptyMagCal(0);
k = 1;
z.schedule = msgToStruct_schedule(data(3:7)); k = k+7;
z.calHist.N = data(k); k = k+1;
z.calHist.Nmax = data(k); k = k+1;
for n = 1:z.calHist.N
    z.calHist.data(n).t = data(k); k = k+1;
    z.calHist.data(n).quality = data(k); k = k+1;
    z.calHist.data(n).qualitySF = data(k); k = k+1;
    z.calHist.data(n).bias(1) = data(k); k = k+1;
    z.calHist.data(n).bias(2) = data(k); k = k+1;
    z.calHist.data(n).bias(3) = data(k); k = k+1;
    z.calHist.data(n).SF(1) = data(k); k = k+1;
    z.calHist.data(n).SF(2) = data(k); k = k+1;
    z.calHist.data(n).SF(3) = data(k); k = k+1;
end
z.lastSolveTime_s = data(k); k = k+1;

z.calInfo = msgToStruct_cal(data(k:k+ 2 + 3 + 3*3-1), 3); k = k+2 + 3+ 3*3;

z.calTime_s = data(k); k = k+1;
z.isUpdateFrmLastRun = data(k); k = k+1;

%'magBuffer',emptyMagDataBuffer , ... %to store mag data

z.magBuffer.N = data(k); k = k+1;
z.magBuffer.Nmax = data(k); k = k+1;
z.magBuffer.tRef = data(k); k = k+1;
z.magBuffer.lastIndx = data(k); k = k+1;

for n = 1:z.magBuffer.Nmax
    z.magBuffer.data(n).dt = data(k); k = k+1;
    z.magBuffer.data(n).x = data(k); k = k+1;
    z.magBuffer.data(n).y = data(k); k = k+1;
    z.magBuffer.data(n).z = data(k); k = k+1;
end

z.magBuffer.lastMag(1) = data(k); k = k+1;
z.magBuffer.lastMag(2) = data(k); k = k+1;
z.magBuffer.lastMag(3) = data(k); k = k+1;
z.magBuffer.xUpIndx = data(k); k = k+1;
z.magBuffer.xLowIndx = data(k); k = k+1;
z.magBuffer.yUpIndx = data(k); k = k+1;
z.magBuffer.yLowIndx = data(k); k = k+1;
z.magBuffer.zUpIndx = data(k); k = k+1;
z.magBuffer.zLowIndx = data(k); k = k+1;

z.tAnomaly = data(k); k = k+1;

z.totalMagHist.N = data(k); k = k+1;
z.totalMagHist.Nmax = data(k); k = k+1;
z.totalMagHist.lastIndx = data(k); k = k+1;
for n = 1:z.totalMagHist.Nmax
    z.totalMagHist.mT(n) = data(k); k = k+1;
end
end

function z = msgToStruct_10731(data)
z = msgToStruct_10730(data);
end

%mag cal state
function z = msgToStruct_10733(data)
z = emptyAccCal(0);
k = 1;
z.schedule = msgToStruct_schedule(data(3:7)); k = k+7;
z.lastSolveTime_s = data(k); k = k+1;
z.calInfo = msgToStruct_cal(data(k:k+ 2 + 3 + 3*3-1), 3); k = k+2 + 3+ 3*3;

z.calTime_s = data(k); k = k+1;
z.isUpdateFrmLastRun = data(k); k = k+1;

z.accBuffer.N = data(k); k = k+1;
z.accBuffer.Nmax = data(k); k = k+1;
z.accBuffer.tRef = data(k); k = k+1;
z.accBuffer.lastIndx = data(k); k = k+1;

for n = 1:z.accBuffer.Nmax
    z.accBuffer.data(n).dt = data(k); k = k+1;
    z.accBuffer.data(n).x = data(k); k = k+1;
    z.accBuffer.data(n).y = data(k); k = k+1;
    z.accBuffer.data(n).z = data(k); k = k+1;
end
end

function z = msgToStruct_10734(data)
z = msgToStruct_10733(data);
end

function z = msgToStruct_10724(data)
z = msgToStruct_10005(data);
end

%walking angle
function z = msgToStruct_10737(data)
k = 1;
z = emptyWalkingAngle(0);
z.schedule = msgToStruct_schedule(data(3:7)); k = k+7;
z.walkAngleOn = data(k); k = k+1;
z.accDataIndx = data(k); k = k+1;
z.accData = msgToStruct_DataSeries(data(k:end, 3));
k = k+ 2 + z.accData.N*(4);
z.accDataDt_ms = data(k); k = k+1;
z.accDataIndx = data(k); k = k+1;
z.Nsteps = data(k); k = k+1;
z.res = msgToStruct_UserHeadingRes(data(k:end)); k = k+8;
%emptyUserHeading
z.userHeading.t = data(k); k = k+1;
z.userHeading.valid = data(k); k = k+1;
z.userHeading.heading = data(k); k = k+1;
z.userHeading.heading_conf = data(k); k = k+1;

z.nHist = data(k); k = k+1;
for n = 1:walkingAngleConsts.histLen
    z.hist(n) = msgToStruct_UserHeadingRes(data(k:end)); k = k+8;
end
end

function z = msgToStruct_UserHeadingRes(data)
k = 1;
z = emptyUserHeadingRes;
z.valid = data(k); k = k+1;
z.uHeading = data(k); k = k+1;
z.wAngle = data(k); k = k+1;
z.weight = data(k); k = k+1;
z.conf = data(k); k = k+1;
z.fwbw = data(k); k = k+1;
z.userHeading = data(k); k = k+1;
z.bodyPos = data(k);
end

function z = msgToStruct_10740(data)
z = emptyAltitude(0);
z.schedule = msgToStruct_schedule(data(3:7)); k = 8;

z.pbData.data = msgToStruct_procBuffer(data(k:end), 1);
procLen = 4 + z.pbData.data.N*(1+1)+ 2; k = k+k+procLen;
data(k) = z.pbData.meanX; k = k+1;
data(k) = z.pbData.deltaMx; k = k+1;

z.hist = msgToStruct_AltHist(data(k:end), z.hist); 
histLen = 4 + 3*z.hist.N + 6; k=k+histLen;
z.stanNoise_iir.tRef = data(k); k = k+1;
z.stanNoise_iir.cSigma = data(k); k = k+1;

z.contextHist = msgToStruct_AltContextHist(data(k:end));
k = k+3*(1+z.contextHist.N);

z.res.t = data(k); k = k+1;
z.res.valid = data(k); k = k+1;
z.res.hBaro_cm = data(k); k = k+1;
z.res.hCal_cm = data(k); k = k+1;
z.res.uVel.speed_cm = data(k); k = k+1;
z.res.uVel.speed_conf = data(k); k = k+1;
z.res.context = data(k); k = k+1;
z.res.contextConf = data(k);
end

function z = msgToStruct_AltHist(data, z)
k = 1;
z.tRef = data(k); k = k+1;
z.N = data(k); k = k+1;
z.Nmax = data(k); k = k+1;
z.lastIndx = data(k); k = k+1;
for n = 1:z.N
    z.v(n) = data(k); k = k+1;
    z.H_cm(n) = data(k); k = k+1;
    z.slope(n) = data(k); k = k+1;
end

z.filt1d.v = data(k); k = k+1;
z.filt1d.slope = data(k); k = k+1;
z.filt1d.c = data(k); k = k+1;
z.filt1d.sE = data(k); k = k+1;
z.filt1d.sC = data(k); k = k+1;
z.filt1d.isStationary = data(k);
end

function z = msgToStruct_AltContextHist(data)
k = 1;
z = emptyAltContextHist;
z.N = data(k); k = k+1;
z.Nmax = data(k); k = k+1;
z.lastIndx = data(k); k = k+1;
for n = 1:z.N
    z.v(n) = data(k); k = k+1;
    z.context(n) = data(k); k = k+1;
    z.slope(n) = data(k); k = k+1;
end
end

function z = msgToStruct_10750(data)
z = msgToStruct_info(data(3:end));
end

function z = msgToStruct_10755(data)
z = msgToStruct_info(data(3:end));
end

function z = msgToStruct_10760(data)
z = msgToStruct_info(data(3:end));
end

function z = msgToStruct_10765(data)
z = msgToStruct_info(data(3:end));
end

function z = msgToStruct_10800(data)
z = msgToStruct_info(data(3:end));
end

function z = msgToStruct_10805(data)
z = msgToStruct_info(data(3:end));
end

function z = msgToStruct_10810(data)
z = msgToStruct_info(data(3:end));
end

function z = msgToStruct_10815(data)
z = msgToStruct_info(data(3:end));
end

function z = msgToStruct_info(data)
z = emptySensorInfo;
k = 1;
z.type = data(k); k = k+1;
z.isDataCal = data(k); k = k+1;
z.range = data(k); k = k+1;
z.sample_ms = data(k); k = k+1;
z.SF = data(k); k = k+1;
%z.vendorName;
z.vendorName = data(k);
end

function z = msgToStruct_10751(data)
z = msgToStruct_cal(data(3:end),3);
end

function z = msgToStruct_10756(data)
z = msgToStruct_cal(data(3:end),3);
end

function z = msgToStruct_10761(data)
z = msgToStruct_cal(data(3:end),3);
end

function z = msgToStruct_10766(data) %pressure
z = msgToStruct_cal(data(3:end),1);
end

function z = msgToStruct_10801(data)
z = msgToStruct_cal(data(3:end),3);
end

function z = msgToStruct_10806(data)
z = msgToStruct_cal(data(3:end),3);
end

function z = msgToStruct_10811(data)
z = msgToStruct_cal(data(3:end),3);
end

function z = msgToStruct_10816(data) %pressure
z = msgToStruct_cal(data(3:end),1);
end

function z = msgToStruct_cal(data, nAxis)
z = emptyCalInfoOP(nAxis);
k = 1;
z.calStatus = data(k); k = k+1;
z.isDiagonal = data(k); k = k+1;
for n = 1:nAxis
    z.bias(n) = data(k); k = k+1;
end

for n = 1:nAxis
    for m = 1:nAxis
        z.SF(n,m) = data(k); k = k+1;
    end
end
end

function z = msgToStruct_10752(data)
z = msgToStruct_acqBuffer(data(3:end),3);
end

function z = msgToStruct_10757(data)
z = msgToStruct_acqBuffer(data(3:end),3);
end

function z = msgToStruct_10762(data)
z = msgToStruct_acqBuffer(data(3:end),3);
end

function z = msgToStruct_10767(data)
z = msgToStruct_acqBuffer(data(3:end),1);
end

function z = msgToStruct_10802(data)
z = msgToStruct_acqBuffer(data(3:end),3);
end

function z = msgToStruct_10807(data)
z = msgToStruct_acqBuffer(data(3:end),3);
end

function z = msgToStruct_10812(data)
z = msgToStruct_acqBuffer(data(3:end),3);
end

function z = msgToStruct_10817(data)
z = msgToStruct_acqBuffer(data(3:end),1);
end

function z = msgToStruct_acqBuffer(data, nAxis)
z = emptyAcqBuffer(nAxis, data(3));
k = 1;
z.N = data(k); k = k+1;
z.lastIndx = data(k); k = k+1;
z.Nmax = data(k); k = k+1;
for n = 1:z.N
    z.t(n) = data(k); k = k+1;
    z.x(n) = data(k); k = k+1;
    if(nAxis == 3)
        z.y(n) = data(k); k = k+1;
        z.z(n) = data(k); k = k+1;
    end
end
end

function z = msgToStruct_10753(data)
z = msgToStruct_procBuffer(data(3:end),3);
end

function z = msgToStruct_10758(data)
z = msgToStruct_procBuffer(data(3:end),3);
end

function z = msgToStruct_10763(data)
z = msgToStruct_procBuffer(data(3:end),3);
end

function z = msgToStruct_10768(data)
z = msgToStruct_procBuffer(data(3:end),1);
end

function z = msgToStruct_10803(data)
z = msgToStruct_procBuffer(data(3:end),3);
end

function z = msgToStruct_10808(data)
z = msgToStruct_procBuffer(data(3:end),3);
end

function z = msgToStruct_10813(data)
z = msgToStruct_procBuffer(data(3:end),3);
end

function z = msgToStruct_10818(data)
z = msgToStruct_procBuffer(data(3:end),1);
end

function z = msgToStruct_procBuffer(data, nAxis)
z = emptyProcBuffer(nAxis,data(3));
k = 1;
z.N = data(k); k = k+1;
z.lastIndx = data(k); k = k+1;
z.Nmax = data(k); k = k+1;
z.t = data(k); k = k+1;
for n = 1:z.N
    z.valid(n) = data(k); k = k+1;
    z.x(n) = data(k); k = k+1;
    if(nAxis == 3)
        z.y(n) = data(k); k = k+1;
        z.z(n) = data(k); k = k+1;
    end
end
end

function z = msgToStruct_DataSeries(data, nAxis)
z = emptyDataSeries_I16(data(2),nAxis);
k = 1;
z.t0 = data(k); k = k+1;
z.N = data(k); k = k+1;
for n = 1:z.N
    z.valid(n) = data(k); k = k+1;
    z.x(n) = data(k); k = k+1;
    if(nAxis == 3)
        z.y(n) = data(k); k = k+1;
        z.z(n) = data(k); k = k+1;
    end
end
end

function z = msgToStruct_schedule(data)
z = emptySchedule;
k = 1;
z.enable  = data(k); k = k+1;
z.lastTime = data(k); k = k+1;
z.interval_ms = data(k); k = k+1;
z.border_ms = data(k); k = k+1;
z.sensors  = data(k);
end

