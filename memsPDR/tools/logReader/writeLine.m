function writeLine(fid, msgData)
%function to read message and convert into structure format
%this function get call from writeLog
if(isempty(msgData) || ~isfield(msgData, 'header') || ~isfield(msgData, 'data'))
    disp('No message');
    return;
end

if(~exist(sprintf('StructToMsg_%5d',msgData.header.id)))
    disp('Message is not converted - define it first');
    return;
end

fprintf(fid, '%d, %d, ', msgData.header.id, msgData.header.timestamp);

%try
eval(sprintf('data = StructToMsg_%5d(msgData.data);', msgData.header.id));
Ok = 1;
%catch
Ok = 0;
%end

for n=1:length(data)
    if (abs(round(data(n))-data(n))< 1E-8)
        fprintf(fid, '%d, ', data(n));
    else
        fprintf(fid, '%f, ', data(n));
    end
end
fprintf(fid,'\n');

end

%%these function convert message to crresponding structure
%%you can add missing function here
%function to set phone info
function data = StructToMsg_10001(z)
data = zeros(1,2);
k = 1;
data(k) = z.modelName; k = k+1;
data(k) = z.deviceId;
end

%function to set initial mems loc
function data = StructToMsg_10002(z)
data = zeros(1,9);
k = 1;
data(k) = z.valid; k = k+1;
data(k) = z.utcTime; k = k+1;
data(k) = z.latCir; k = k+1;
data(k) = z.lonCir; k = k+1;
data(k) = z.alt_cm; k = k+1;
data(k) = z.posConf.major_cm; k = k+1;
data(k) = z.posConf.minor_cm; k = k+1;
data(k) = z.posConf.alt_cm; k = k+1;
data(k) = z.posConf.ang_deg;
end

%function to set user info
function data = StructToMsg_10003(z)
data = zeros(1,4);
k = 1;
data(k) = z.height_cm; k = k+1;
data(k) = z.weight_kg; k = k+1;
data(k) = z.age_year; k = k+1;
data(k) = z.gender;
end

%function to set stride length calibration info
function data = StructToMsg_10004(z)
data = zeros(1,5);
k = 1;
data(k) = z.refDist_cm; k = k+1;
data(k) = z.Nsteps; k = k+1;
data(k) = z.dT_s; k = k+1;
data(k) = z.Context_Horiz; k= k+1;
data(k) = z.posSource;
end

%function to control mems init enable or disable
function data = StructToMsg_10101(z)
data = zeros(1,1);
k = 1;
data(k) = z.switch;
end

function data = StructToMsg_10102(z)
data = zeros(1,5*z.nSens+2);
k = 1;
data(k) = z.nSens; k = k+1;
data(k) = z.sensSrc; k = k+1;

for n = 1:z.nSens
    %u can replace with StructToMsg_info
    data(k) = z.sensorInfo(n).type; k = k+1;
    data(k) = z.sensorInfo(n).isDataCal; k = k+1;
    data(k) = z.sensorInfo(n).range; k = k+1;
    data(k) = z.sensorInfo(n).sample_ms; k = k+1;
    data(k) = z.sensorInfo(n).SF; k = k+1;
    %data(k) = z.sensorInfo(n).vendorName;
    data(k) = -1; k = k+1;
end
end

function data =  StructToMsg_10103(z)
data = zeros(1,1);
k = 1;
data(k) = z.controlMask;
end

function data =  StructToMsg_10104(z)
data = zeros(1,1);
k = 1;
data(k) = z.controlMask;
end

function data = StructToMsg_10201(z)
data = zeros(1,500);
k = 1;

data(k) = z.timestamp; k = k+1;
data(k) = z.nSens; k = k+1;
for n = 1:z.nSens
    data(k) = z.data(n).type; k = k+1;
    data(k) = z.data(n).N; k = k+1;
    nDim = bitshift(bitand(z.data(n).type,memsConsts.AXIS_MASK),-6);
    for p = 1:z.data(n).N
        data(k) = z.data(n).datablock(p).dt; k = k+1;
        data(k) = z.data(n).datablock(p).x; k = k+1;
        if(nDim==3)
            data(k) = z.data(n).datablock(p).y; k = k+1;
            data(k) = z.data(n).datablock(p).z; k = k+1;
        end
    end
end
data = data(1:k-1);
end

function data = StructToMsg_10202(z)
data = zeros(1,12);
k = 1;
data(k) = z.Nsats; k = k+1;
data(k) = z.loc.valid; k = k+1;
data(k) = z.loc.utcTime; k = k+1;
data(k) = z.loc.latCir; k = k+1;
data(k) = z.loc.lonCir; k = k+1;
data(k) = z.loc.alt_cm; k = k+1;
data(k) = z.loc.posConf.major_cm; k = k+1;
data(k) = z.loc.posConf.minor_cm; k = k+1;
data(k) = z.loc.posConf.alt_cm; k = k+1;
data(k) = z.loc.posConf.ang_deg; k = k+1;
data(k) = z.speed_cm.val; k = k+1;
data(k) = z.speed_cm.conf; k = k+1;
data(k) = z.bearing_degs.val; k = k+1;
data(k) = z.bearing_degs.conf;
end

function data = StructToMsg_10250(z)
k = 1;
data(k) = z.sensType; k = k+1;
data(k:k+ 2 + 3 + 3*3-1) = StructToMsg_cal(z.calInfo, 3);
end

function data = StructToMsg_10251(z)
data = zeros(1,16);
k = 1;
data(k) = z.infoType; k = k+1;
data(k) = z.calTime_s; k = k+1;
data(k:k+ 2 + 3 + 3*3-1) = StructToMsg_cal(z.calInfo, 3);
end

function data = StructToMsg_10252(z)
data = zeros(1,16);
k = 1;
data(k) = z.infoType; k = k+1;
data(k) = z.calTime_s; k = k+1;
data(k:k+ 2 + 3 + 3*3-1) = StructToMsg_cal(z.calInfo, 3);
end

function data = StructToMsg_10253(z)
data = zeros(1,75);
k = 1;
data(k) = z.infoType; k = k+1;
data(k) = z.calTime_s; k = k+1;
data(k:k+ 2 + 3 + 3*3-1) = StructToMsg_cal(z.calInfo, 3); k = k+2 + 3+ 3*3;
data(k) = z.calHist.N; k = k+1;
data(k) = z.calHist.Nmax; k = k+1;
for n = 1:z.calHist.N
    data(k) = z.calHist.data(n).t; k = k+1;
    data(k) = z.calHist.data(n).quality; k = k+1;
    data(k) = z.calHist.data(n).qualitySF; k = k+1;
    data(k) = z.calHist.data(n).bias(1); k = k+1;
    data(k) = z.calHist.data(n).bias(2); k = k+1;
    data(k) = z.calHist.data(n).bias(3); k = k+1;
    data(k) = z.calHist.data(n).SF(1); k = k+1;
    data(k) = z.calHist.data(n).SF(2); k = k+1;
    data(k) = z.calHist.data(n).SF(3); k = k+1;
    data(k) = z.calHist.data(n).SFI(1); k = k+1;
    data(k) = z.calHist.data(n).SFI(2); k = k+1;
    data(k) = z.calHist.data(n).SFI(3); k = k+1;
end
end

%function to set knobs
function data = StructToMsg_10203(z)
data = zeros(1,16);
k = 1;
data(k) = z.modX; k = k+1;
data(k) = z.gbias_mode; k = k+1;
data(k) = z.stopActionFilter; k = k+1;
data(k) = z.dynamic_accel_mode; k = k+1;
data(k) = z.sensorFlags(1); k = k+1;
data(k) = z.sensorFlags(2); k = k+1;
data(k) = z.sensorFlags(3); k = k+1;
data(k) = z.gyro_time_constant; k = k+1;
data(k) = z.gbias_thresh; k = k+1;
data(k) = z.gbias_mag_th_sc; k = k+1;
data(k) = z.gbias_acc_th_sc; k = k+1;
data(k) = z.gbias_gyro_th_sc; k = k+1;
data(k) = z.ATime; k = k+1;
data(k) = z.MTime; k = k+1;
data(k) = z.PTime; k = k+1;
data(k) = z.FrTime;
end

%request messages
%tag
function data = StructToMsg_10402(z)
data = [];
end

%step
function data = StructToMsg_10403(z)
data = [];
end

%stride
function data = StructToMsg_10404(z)
data = [];
end

%speed
function data = StructToMsg_10405(z)
data = [];
end

%bodyPos
function data = StructToMsg_10410(z)
data = [];
end

%userHeading
function data = StructToMsg_10411(z)
data = [];
end

function data = StructToMsg_10501(z)
k = 1;
data(k) = z.time ; k = k+1;
data(k) = z.latCir; k = k+1;
data(k) = z.lonCir; k = k+1;
data(k) = z.alt_cm; k = k+1;
data(k) = z.UTC;
end

function data = StructToMsg_10502(z)
data = [];
k = 1;
data(k) = z.time ; k = k+1;
data(k) = z.dt; k = k+1;
data(k) = z.N; k = k+1;
for n = 1:z.N
    data(k) = z.yaw_mdeg(n); k = k+1;
    data(k) = z.pitch_mdeg(n);k = k+1;
    data(k) = z.roll_mdeg(n); k = k+1;
end
end

function data = StructToMsg_10503(z)
data = [];
end

function data = StructToMsg_10504(z)
k = 1;
data(k) =  z.time; k = k+1;
data(k) =  z.context; 
end

function data = StructToMsg_10505(z)
k = 1;
data(k) = z.tLastStep; k = k+1;
data(k) = z.stepCount;
%data(k) = z.step_conf;
end

function data = StructToMsg_10506(z)
k = 1;
data(k) = z.time; k = k+1;
data(k) = z.dist_m; 
end

function data = StructToMsg_10508(z)
k = 1;
data(k) = z.time; k = k+1;
data(k) = z.carryPos; 
end

%update Acq buffer
function data = StructToMsg_10708(z)
data = 0;
end

%update Acq buffer
function data = StructToMsg_10709(z)
data = StructToMsg_10201(z);
end

%mag model setpos
function data = StructToMsg_10711(z)
data = StructToMsg_10002(z);
end

function data = StructToMsg_10712(z)
data = zeros(1,4);
k = 1;
data(k) = z.valid; k = k+1;
data(k) = z.E_nT; k = k+1;
data(k) = z.N_nT; k = k+1;
data(k) = z.U_nT;
end

function data = StructToMsg_10713(z)
data = StructToMsg_10712(z);
end


function data = StructToMsg_10721(z) %att
data = StructToMsg_schedule(z.schedule); k = 6;
data(k) = z.init.filter; k = k+1;
data(k) = z.init.gbias; k = k+1;
data(k) = z.init.sp_resetCntr; k = k+1;
data(k:k+15) = StructToMsg_10203(z.knobs); k = k+16;

data(k) = z.att.t0; k = k+1;
data(k) = z.att.dt; k = k+1;
data(k) = z.att.N; k = k+1;
for n = 1:z.att.N
    data(k) = z.att.valid(n); k = k+1;
    data(k) = z.att.yaw(n); k = k+1;
    data(k) = z.att.roll(n); k = k+1;
    data(k) = z.att.pitch(n); k = k+1;
    data(k) = z.att.yaw_conf(n); k = k+1;
    data(k) = z.att.roll_conf(n); k = k+1;
    data(k) = z.att.pitch_conf(n); k = k+1;
end

data(k:k+55) = StructToMsg_AttMergeAction(z.mergeAction); k = k+56;

data(k) = z.gbiasState.wait; k = k+1;
data(k) = z.gbiasState.wait2; k = k+1;
data(k) = z.gbiasState.wait3; k = k+1;
data(k) = z.gbiasState.gbiascnt; k = k+1;
data(k) = z.gbiasState.gbias_mode_change; k = k+1;
data(k) = z.gbiasState.Preset; k = k+1;
data(k) = z.gbiasState.gval; k = k+1;

data(k) = z.KF.init; k = k+1;
data(k:k+attConsts.NState-1) = z.KF.x'; k = k + attConsts.NState;
%storing only lower portion
for n = 1:attConsts.NState
    for m = 1:n
        data(k) = z.KF.P(n,m); k = k+1;
    end
end

histBuffSize = 1 + 9 + attConsts.kf_gbufsize*3 + 3 + 3*(3+ 3*attConsts.kf_dbufsize) + 2+ attConsts.kf_diffBufSize;
data(k:k+histBuffSize-1) =  StructToMsg_AttHistbuff(z.histbuff);
k = k + histBuffSize;

data(k:k+3) = z.q_in; k = k+4;
data(k:k+2) = z.gbias'; k = k+3;
data(k) = z.count; k = k+1;
data(k) = z.lastRun;
end



%Addition for CarryPosition
function data = StructToMsg_10715(z)
data = StructToMsg_WriteCarryPositionState(z);
end

function data = StructToMsg_10716(z)
data = StructToMsg_WriteCarryPositionState(z);
end

function data = StructToMsg_WriteCarryPositionState(z)
data = zeros(1,5+14 + (6*length(z.filterX)));
data_1 = StructToMsg_schedule(z.schedule);
data(1:5) = data(1:5)+data_1;
k=6;
data(k) = z.carryPositionRes.carryPosition;k=k+1;
data(k) = z.carryPositionRes.conf;k=k+1;
data(k) = z.currentSample;k=k+1;
data(k) = z.sinceLastUpdate; k=k+1;
data(k) = z.currentCarryPosition;k=k+1;
data(k) = z.latestSampleLocation;k=k+1;
data(k) = z.filterBufferLocation;k=k+1;
filternames = ['filterX '; 'filter1Y'; 'filter2Y'; 'filter3Y'; 'filter4Y'; 'filter5Y'];
filternames = cellstr(filternames);
for i=1:length(z.filterX)
   
        data(k) = z.filterX(i);k=k+1; 
   
end
for i=1:length(z.filter1Y)
 data(k) = z.filter1Y(i);k=k+1; 
end
for i=1:length(z.filter2Y)
  data(k) = z.filter2Y(i);k=k+1; 
end
for i=1:length(z.filter3Y)
  data(k) = z.filter3Y(i);k=k+1; 
end
for i=1:length(z.filter4Y)
 data(k) = z.filter4Y(i);k=k+1; 
end
for i=1:length(z.filter5Y)
 data(k) = z.filter5Y(i);k=k+1; 
end
data(k) = z.onDeskTimeMap;k=k+1;
data(k) = z.inHandTimeMap;k=k+1;
data(k) = z.nearHeadTimeMap;k=k+1;
data(k) = z.shirtPocketTimeMap;k=k+1;
data(k) = z.trouserPocketTimeMap;k=k+1;
data(k) = z.armSwingTimeMap;k=k+1;
data(k) = z.confidentState;

end

function data = StructToMsg_AttMergeAction(z)
k = 1;
data(k:k+12) = z.move_merge_table(1,1:13); k = k+13;
data(k:k+12) = z.move_merge_table(2,1:13); k = k+13;
data(k:k+12) = z.acc_merge_table(1,1:13); k = k+13;
data(k:k+12) = z.acc_merge_table(2,1:13); k = k+13;
data(k) = z.dcomb_th; k = k+1;
data(k) = z.dcombRatio; k = k+1;
data(k) = z.daccRatio; k = k+1;
data(k) = z.dgyroRatio;
end

function data = StructToMsg_AttHistbuff(z)
k = 1;
data(k) =  z.init; k = k+1;
data(k:k+2) = z.Tprev(1,:); k = k+3;
data(k:k+2) = z.Tprev(2,:); k = k+3;
data(k:k+2) = z.Tprev(3,:); k = k+3;

data(k:k+3+ 3*attConsts.kf_gbufsize-1) = StructToMsg_AttVector(z.propabs_buf, 3); k = k+3+ 3*z.propabs_buf.Nmax;
data(k:k+3+ 3*attConsts.kf_dbufsize-1) = StructToMsg_AttVector(z.mag_buf, 3); k = k+3+ 3*z.mag_buf.Nmax;
data(k:k+3+ 3*attConsts.kf_dbufsize-1) = StructToMsg_AttVector(z.acc_buf, 3); k = k+3+ 3*z.acc_buf.Nmax;
data(k:k+3+ 3*attConsts.kf_dbufsize-1) = StructToMsg_AttVector(z.gyro_buf, 3); k = k+3+ 3*z.gyro_buf.Nmax;

data(k) = z.slopFilterData.init; k = k+1;
% z.slopFilterData.halffiltCoeff; doesnt need to read or write, it is
% having default value
data(k) = z.slopFilterData.Nmax; k = k+1;
for n = 1:z.slopFilterData.Nmax
    data(k) = z.slopFilterData.data(1,n); k = k+1;
end
end

function data = StructToMsg_AttVector(z, nAxis)
k = 1;
data(k) = z.N; k = k+1;
data(k) = z.Nmax; k = k+1;
data(k) = z.scale; k = k+1;
for n = 1:z.Nmax
    data(k) = z.data(1,n); k = k+1;
    if(nAxis>1)
        data(k) = z.data(2,n); k = k+1;
    end
    if(nAxis>2)
        data(k) = z.data(3,n); k = k+1;
    end
end
end

%getAttitude
function data = StructToMsg_10722(z) %att
data = zeros(1, 7+z.N*3);
k = 1;
data(k) = z.t0; k = k+1;
data(k) = z.N; k = k+1;
data(k) = z.valid; k = k+1;
data(k) = z.dt_ms; k = k+1;
for n = 1:z.N
    data(k) = z.yaw(n); k = k+1;
    data(k) = z.roll(n); k = k+1;
    data(k) = z.pitch(n); k = k+1;
end
data(k) = z.yaw_conf; k = k+1;
data(k) = z.roll_conf; k = k+1;
data(k) = z.pitch_conf;
end

function data = StructToMsg_10723(z) %att
data = StructToMsg_10722(z);
end

%mag cal state
function data = StructToMsg_10730(z)
data = StructToMsg_schedule(z.schedule); k = 6;
data(k) = z.calHist.N; k = k+1;
data(k) = z.calHist.Nmax; k = k+1;
for n = 1:z.calHist.N
    data(k) = z.calHist.data(n).t; k = k+1;
    data(k) = z.calHist.data(n).quality; k = k+1;
    data(k) = z.calHist.data(n).qualitySF; k = k+1;
    data(k) = z.calHist.data(n).bias(1); k = k+1;
    data(k) = z.calHist.data(n).bias(2); k = k+1;
    data(k) = z.calHist.data(n).bias(3); k = k+1;
    data(k) = z.calHist.data(n).SF(1); k = k+1;
    data(k) = z.calHist.data(n).SF(2); k = k+1;
    data(k) = z.calHist.data(n).SF(3); k = k+1;
end
data(k) = z.lastSolveTime_s; k = k+1;

data(k:k+ 2 + 3 + 3*3-1) = StructToMsg_cal(z.calInfo, 3); k = k+2 + 3+ 3*3;

data(k) = z.calTime_s; k = k+1;
data(k) = z.isUpdateFrmLastRun; k = k+1;

%'magBuffer',emptyMagDataBuffer , ... %to store mag data

data(k) = z.magBuffer.N; k = k+1;
data(k) = z.magBuffer.Nmax; k = k+1;
data(k) = z.magBuffer.tRef; k = k+1;
data(k) = z.magBuffer.lastIndx; k = k+1;

for n = 1:z.magBuffer.Nmax
    data(k) = z.magBuffer.data(n).dt; k = k+1;
    data(k) = z.magBuffer.data(n).x; k = k+1;
    data(k) = z.magBuffer.data(n).y; k = k+1;
    data(k) = z.magBuffer.data(n).z; k = k+1;
end

data(k) = z.magBuffer.lastMag(1); k = k+1;
data(k) = z.magBuffer.lastMag(2); k = k+1;
data(k) = z.magBuffer.lastMag(3); k = k+1;
data(k) = z.magBuffer.xUpIndx; k = k+1;
data(k) = z.magBuffer.xLowIndx; k = k+1;
data(k) = z.magBuffer.yUpIndx; k = k+1;
data(k) = z.magBuffer.yLowIndx; k = k+1;
data(k) = z.magBuffer.zUpIndx; k = k+1;
data(k) = z.magBuffer.zLowIndx; k = k+1;

data(k) = z.tAnomaly; k = k+1;

data(k) = z.totalMagHist.N; k = k+1;
data(k) = z.totalMagHist.Nmax; k = k+1;
data(k) = z.totalMagHist.lastIndx; k = k+1;
for n = 1:z.totalMagHist.Nmax
    data(k) = z.totalMagHist.mT(n); k = k+1;
end
end

function data = StructToMsg_10731(z)
data = StructToMsg_10730(z);
end

%acc cal state
function data = StructToMsg_10733(z)
data = StructToMsg_schedule(z.schedule); k = 6;
data(k) = z.lastSolveTime_s; k = k+1;

data(k:k+ 2 + 3 + 3*3-1) = StructToMsg_cal(z.calInfo, 3); k = k+2 + 3+ 3*3;

data(k) = z.calTime_s; k = k+1;
data(k) = z.isUpdateFrmLastRun; k = k+1;

data(k) = z.accBuffer.N; k = k+1;
data(k) = z.accBuffer.Nmax; k = k+1;
data(k) = z.accBuffer.tRef; k = k+1;
data(k) = z.accBuffer.lastIndx; k = k+1;

for n = 1:z.accBuffer.Nmax
    data(k) = z.accBuffer.data(n).dt; k = k+1;
    data(k) = z.accBuffer.data(n).x; k = k+1;
    data(k) = z.accBuffer.data(n).y; k = k+1;
    data(k) = z.accBuffer.data(n).z; k = k+1;
end
end

function data = StructToMsg_10734(z)
data = StructToMsg_10733(z);
end

function data = StructToMsg_10724(z)
data = StructToMsg_10203(z);
end

%walking angle
function data = StructToMsg_10737(z)
data = StructToMsg_schedule(z.schedule); k = 6;
data(k) = z.walkAngleOn; k = k+1;
data(k) = z.accDataIndx; k = k+1;
data(k:k + 2 + z.accData.N*(4)-1) = StructToMsg_DataSeries(z.accData, 3); 
k = k+ 2 + z.accData.N*(4);
data(k) = z.accDataDt_ms; k = k+1;
data(k) = z.accDataIndx; k = k+1;
data(k) = z.Nsteps; k = k+1;

data(k:k+7) = StructToMsg_UserHeadingRes(z.res); k = k+8;
%emptyUserHeading
data(k) = z.userHeading.t; k = k+1;
data(k) = z.userHeading.valid; k = k+1;
data(k) = z.userHeading.heading; k = k+1;
data(k) = z.userHeading.heading_conf; k = k+1;

data(k) = z.nHist; k = k+1;
for n = 1:walkingAngleConsts.histLen
    data(k:k+7) =  StructToMsg_UserHeadingRes(z.hist(n)); k = k+8;
end
end

function data = StructToMsg_UserHeadingRes(z)
k = 1;
data(k) = z.valid; k = k+1;
data(k) = z.uHeading; k = k+1;
data(k) = z.wAngle; k = k+1;
data(k) = z.weight; k = k+1;
data(k) = z.conf; k = k+1;
data(k) = z.fwbw; k = k+1;
data(k) = z.userHeading; k = k+1;
data(k) = z.bodyPos;
end

function data = StructToMsg_10740(z)
data = StructToMsg_schedule(z.schedule); k = 6;

procLen = 4 + z.pbData.data.N*(1+1)+ 2;
data(k:k+procLen-1) = StructToMsg_procBuffer(z.pbData.data,1); k = k+k+procLen;
data(k) = z.pbData.meanX; k = k+1;
data(k) = z.pbData.deltaMx; k = k+1;

histLen = 4 + 3*z.hist.N + 6;
data(k:k+histLen-1) = StructToMsg_AltHist(z.hist); k=k+histLen;
data(k) = z.stanNoise_iir.tRef; k = k+1;
data(k) = z.stanNoise_iir.cSigma; k = k+1;

data(k:k+3*(1+z.contextHist.N)-1) = StructToMsg_AltContextHist(z.contextHist);
k = k+3*(1+z.contextHist.N);

data(k) = z.res.t; k = k+1;
data(k) = z.res.valid; k = k+1;
data(k) = z.res.hBaro_cm; k = k+1;
data(k) = z.res.hCal_cm; k = k+1;
data(k) = z.res.uVel.speed_cm; k = k+1;
data(k) = z.res.uVel.speed_conf; k = k+1;
data(k) = z.res.context; k = k+1;
data(k) = z.res.contextConf;
end

function data = StructToMsg_AltHist(z)
k = 1;
data = zeros(1, 4 + 3*z.N + 6);
data(k) = z.tRef; k = k+1;
data(k) = z.N; k = k+1;
data(k) = z.Nmax; k = k+1;
data(k) = z.lastIndx; k = k+1;
for n = 1:z.N
    data(k) = z.v(n); k = k+1;
    data(k) = z.H_cm(n); k = k+1;
    data(k) = z.slope(n); k = k+1;
end

data(k) = z.filt1d.v; k = k+1;
data(k) = z.filt1d.slope; k = k+1;
data(k) = z.filt1d.c; k = k+1;
data(k) = z.filt1d.sE; k = k+1;
data(k) = z.filt1d.sC; k = k+1;
data(k) = z.filt1d.isStationary;
end

function data = StructToMsg_AltContextHist(z)
k = 1;
data = zeros(1,3*(1+z.N));
data(k) = z.N; k = k+1;
data(k) = z.Nmax; k = k+1;
data(k) = z.lastIndx; k = k+1;
for n = 1:z.N
    data(k) = z.v(n); k = k+1;
    data(k) = z.context(n); k = k+1;
    data(k) = z.slope(n); k = k+1;
end
end

function data = StructToMsg_10750(z)
data = StructToMsg_info(z);
end

function data = StructToMsg_10755(z)
data = StructToMsg_info(z);
end

function data = StructToMsg_10760(z)
data = StructToMsg_info(z);
end

function data = StructToMsg_10765(z)
data = StructToMsg_info(z);
end

function data = StructToMsg_10800(z)
data = StructToMsg_info(z);
end

function data = StructToMsg_10805(z)
data = StructToMsg_info(z);
end

function data = StructToMsg_10810(z)
data = StructToMsg_info(z);
end

function data = StructToMsg_10815(z)
data = StructToMsg_info(z);
end

function data = StructToMsg_info(z)
data = zeros(1,6);
k = 1;
data(k) = z.type; k = k+1;
data(k) = z.isDataCal; k = k+1;
data(k) = z.range; k = k+1;
data(k) = z.sample_ms; k = k+1;
data(k) = z.SF; k = k+1;
%data(k) = z.vendorName;
data(k) = -1;
end

function data = StructToMsg_10751(z)
data = StructToMsg_cal(z,3);
end

function data = StructToMsg_10756(z)
data = StructToMsg_cal(z,3);
end

function data = StructToMsg_10761(z)
data = StructToMsg_cal(z,3);
end

function data = StructToMsg_10766(z) %pressure
data = StructToMsg_cal(z,1);
end

function data = StructToMsg_10801(z)
data = StructToMsg_cal(z,3);
end

function data = StructToMsg_10806(z)
data = StructToMsg_cal(z,3);
end

function data = StructToMsg_10811(z)
data = StructToMsg_cal(z,3);
end

function data = StructToMsg_10816(z) %pressure
data = StructToMsg_cal(z,1);
end

function data = StructToMsg_cal(z, nAxis)
data = zeros(1,2 + nAxis + nAxis*nAxis);
k = 1;
data(k) = z.calStatus; k = k+1;
data(k) = z.isDiagonal; k = k+1;
for n = 1:nAxis
    data(k) = z.bias(n); k = k+1;
end

for n = 1:nAxis
    for m = 1:nAxis
        data(k) = z.SF(n,m); k = k+1;
    end
end
end

function data = StructToMsg_10752(z)
data = StructToMsg_acqBuffer(z,3);
end

function data = StructToMsg_10757(z)
data = StructToMsg_acqBuffer(z,3);
end

function data = StructToMsg_10762(z)
data = StructToMsg_acqBuffer(z,3);
end

function data = StructToMsg_10767(z)
data = StructToMsg_acqBuffer(z,1);
end

function data = StructToMsg_10802(z)
data = StructToMsg_acqBuffer(z,3);
end

function data = StructToMsg_10807(z)
data = StructToMsg_acqBuffer(z,3);
end

function data = StructToMsg_10812(z)
data = StructToMsg_acqBuffer(z,3);
end

function data = StructToMsg_10817(z)
data = StructToMsg_acqBuffer(z,1);
end

function data = StructToMsg_acqBuffer(z, nAxis)
data = zeros(1, 3 + z.N*(nAxis+1));
k = 1;
data(k) = z.N; k = k+1;
data(k) = z.lastIndx; k = k+1;
data(k) = z.Nmax; k = k+1;
for n = 1:z.N
    data(k) = z.t(n); k = k+1;
    data(k) = z.x(n); k = k+1;
    if(nAxis == 3)
        data(k) = z.y(n); k = k+1;
        data(k) = z.z(n); k = k+1;
    end
end
end

function data = StructToMsg_10753(z)
data = StructToMsg_procBuffer(z,3);
end

function data = StructToMsg_10758(z)
data = StructToMsg_procBuffer(z,3);
end

function data = StructToMsg_10763(z)
data = StructToMsg_procBuffer(z,3);
end

function data = StructToMsg_10768(z)
data = StructToMsg_procBuffer(z,1);
end

function data = StructToMsg_10803(z)
data = StructToMsg_procBuffer(z,3);
end

function data = StructToMsg_10808(z)
data = StructToMsg_procBuffer(z,3);
end

function data = StructToMsg_10813(z)
data = StructToMsg_procBuffer(z,3);
end

function data = StructToMsg_10818(z)
data = StructToMsg_procBuffer(z,1);
end

function data = StructToMsg_procBuffer(z, nAxis)
data = zeros(1, 4 + z.N*(nAxis+1));
k = 1;
data(k) = z.N; k = k+1;
data(k) = z.lastIndx; k = k+1;
data(k) = z.Nmax; k = k+1;
data(k) = z.t; k=k+1;
for n = 1:z.N
    data(k) = z.valid(n); k = k+1;
    data(k) = z.x(n); k = k+1;
    if(nAxis == 3)
        data(k) = z.y(n); k = k+1;
        data(k) = z.z(n); k = k+1;
    end
end
end

function data = StructToMsg_DataSeries(z, nAxis)
data = zeros(1, 2 + z.N*(nAxis+1));
k = 1;
data(k) = z.t0; k = k+1;
data(k) = z.N; k = k+1;
for n = 1:z.N
    data(k) = z.valid(n); k = k+1;
    data(k) = z.x(n); k = k+1;
    if(nAxis == 3)
        data(k) = z.y(n); k = k+1;
        data(k) = z.z(n); k = k+1;
    end
end
end

function data = StructToMsg_schedule(z)
data = zeros(1,5);
k = 1;
data(k) = z.enable; k = k+1;
data(k) = z.lastTime ; k = k+1;
data(k) = z.interval_ms; k = k+1;
data(k) = z.border_ms ; k = k+1;
data(k) = z.sensors;
end