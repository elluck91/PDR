function [result, memsState] = logReplayer(varargin)
%main function to play back log file with variable inputs
%output will contain memsState which holds the algorithm state
%and results which is requested
%input format should be "Name in string", value
% example
% [result] = logReplayer(); or logReplayer('fname', 'ST_Log_PDR.txt', 'topdir', 'C:/User/jainm1')

result = [];
memsState = [];

logging = [];
memsControl = [];
memsConfig = [];

nSysStatus = 0;
nTag = 0;
nStep = 0;
nStride = 0;
nSpeed = 0;
nCalInfo = 0;
nCalStatus = 0;
nOrientation = 0;
nContext = 0;
ncarryPos = 0;
nUserHeading = 0;
 
nGTLoc = 0;
nGTYPR = 0;
nGTWA = 0;
nGTContext = 0;
nGTSteps = 0;
nGTDist = 0;
nGTUserHeading = 0;
nGTBodyPos = 0;

sensorRequired = emptySensorRequire;
isControlDefine = 0;
isConfigSet = 0;

topdir = './';
fname = 'ST_PDR_Log.txt';

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
            isControlDefine = 1;
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

%set default logging level here
if(isempty(logging))
    logging = defaultLogging;
end

%defaULT state of mems .. enable all tech
if(isempty(memsControl))
    memsControl = defaultMemsControl;
end

if(isempty(memsControl))
   memsConfig = defaultMemsConfig;
end
%it will create main structure to hold all state and output
if(isempty(memsState))
    memsState = memsLoader();
end

%set default control
memsState.logging = logging;
[memsState, sensorRequired]  = memsSetControl(memsState, memsControl , 0);

fileID = fopen([topdir fname],'r');

if(fileID==-1)
    error([fname ' file not able to open:exit']);
end

printOnScreen(['Start Processing Log file :' fname], memsState.logging.verbose);

tline = fgetl(fileID);
tLastTime = 0;
while ischar(tline)
    %real line and identify the message
    [msg, Ok] = readLine(tline);
    if(~Ok)
        tline = fgetl(fileID);
        continue;
    end
    if(msg.header.timestamp-tLastTime < -1000)
        tLastTime = msg.header.timestamp;
        printOnScreen(['Processing timestamp going backward :' num2str(tLastTime)], memsState.logging.verbose);
    end
    if(msg.header.timestamp-tLastTime > 10000)
        tLastTime = msg.header.timestamp;
        printOnScreen(['Processing till timestamp :' num2str(tLastTime)], memsState.logging.verbose);
    end
    switch(msg.header.id)
        case memsIDs.memsSetPhoneInfo
            memsState.info.phone = memsSetPhoneInfo(memsState.info.phone, msg.data, msg.header.timestamp, memsState.logging);
        case memsIDs.memsSetLoc
            memsState = memsSetLoc(memsState, msg.data, msg.header.timestamp);
        case memsIDs.memsSetUserInfo
            memsState = memsSetUserInfo(memsState, msg.data, msg.header.timestamp, memsState.logging);
        case memsIDs.memsSetStrideCal
            memsState = memsSetStrideCal(memsState, msg.data, msg.header.timestamp, memsState.logging);
        case memsIDs.memsInit
            if(~isConfigSet)
               [~, memsState.data] = memsSetConfig(memsState.data, memsConfig, msg.header.timestamp, memsState.logging);
               isConfigSet = 1;
            end
            memsState = memsInit(memsState, msg.data, msg.header.timestamp, memsState.logging);
        case memsIDs.memsConfig
            [~, memsState.data] = memsSetConfig(memsState.data, msg.data, msg.header.timestamp, memsState.logging);
            isConfigSet = 1;
        case memsIDs.memsControl
            if(~isControlDefine)
                [memsState, sensorRequired]  = memsSetControl(memsState, msg.data, msg.header.timestamp);
            end
        case memsIDs.memsReset
            memsState = memsReset(memsState, msg.data, msg.header.timestamp, memsState.logging);
        case memsIDs.memsSensData
            memsState.data = memsDataHandler(memsState.data, msg.data, msg.header.timestamp, memsState.logging);
            memsState = memsProcessing(memsState, msg.header.timestamp);
        case memsIDs.locationHandler
            memsState = memsLocHandler(memsState, msg.data, msg.header.timestamp);
            
           %to set attitude knobs
        case memsIDs.memsAttSetKnobs
            memsState = memsSetAttKnobs(memsState,  msg.data, msg.header.timestamp);
            
            %request
        case memsIDs.memsGetSysStatus
            status = memsGetSysStatus(memsState, msg.header.timestamp);
            nSysStatus = nSysStatus+1;
            result.SysStatus(nSysStatus) = createMsg(status,msg.header.timestamp,memsIDs.memsGetSysStatus);
        case memsIDs.memsGetTag
            tag = memsGetTag(memsState, msg.header.timestamp);
            nTag = nTag+1;
            result.Tag(nTag) = createMsg(tag,msg.header.timestamp,memsIDs.memsTag);
        case memsIDs.memsGetStep
            steps = memsGetStep(memsState, msg.header.timestamp);
            nStep = nStep+1;
            result.Step(nStep) = createMsg(steps,msg.header.timestamp,memsIDs.memsStep);
        case memsIDs.memsGetStride
            stide = memsGetStride(memsState, msg.header.timestamp);
            nStride = nStride+1;
            result.Stride(nStride) = createMsg(stide,msg.header.timestamp,memsIDs.memsStride);
        case memsIDs.memsGetSpeed
            speed = memsGetSpeed(memsState, msg.header.timestamp);
            nSpeed = nSpeed+1;
            result.Speed(nSpeed) = createMsg(speed,msg.header.timestamp,memsIDs.memsSpeed);
        case memsIDs.memsCalInfo
            calInfo = memsCalInfo(memsState, msg.header.timestamp);
            nCalInfo = nCalInfo+1;
            result.CalInfo(nCalInfo) = createMsg(calInfo,msg.header.timestamp,memsIDs.memsCalInfo);
        case memsIDs.memsGetCalStatus
            calStatus = memsGetCalStatus(memsState, msg.header.timestamp);
            nCalStatus = nCalStatus+1;
            result.CalStatus(nCalStatus) = createMsg(calStatus,msg.header.timestamp,memsIDs.memsCalStatus);
        case memsIDs.memsGetOrientation
            orientation = memsGetOrientation(memsState, msg.header.timestamp);
            nOrientation = nOrientation+1;
            result.Orientation(nOrientation) = createMsg(orientation,msg.header.timestamp,memsIDs.memsOrientation);
        case memsIDs.memsGetContext
            context = memsGetContext(memsState, msg.header.timestamp);
            nContext = nContext+1;
            result.Context(nContext) = createMsg(context,msg.header.timestamp,memsIDs.memsContext);
        case memsIDs.memsGetCarryPos
            carryPos = memsGetCarryPos(memsState, msg.header.timestamp);
            ncarryPos = ncarryPos+1;
            result.carryPos(ncarryPos) = createMsg(carryPos,msg.header.timestamp,memsIDs.memsGetCarryPos);
        case memsIDs.memsGetUserHeading
            uH = memsGetUserHeading(memsState, msg.header.timestamp);
            nUserHeading = nUserHeading+1;
            result.UserHeading(nUserHeading) = createMsg(uH,msg.header.timestamp,memsIDs.memsUserHeading);
            
            %Ground Truth
        case memsIDs.memsGTLoc
            nGTLoc = nGTLoc+1;
            result.GTLoc(nGTLoc) = msg.data;
        case memsIDs.memsGTYPR
            nGTYPR = nGTYPR+1;
            result.GTYPR(nGTYPR) = msg.data;
        case memsIDs.memsGTWA
            nGTWA = nGTWA+1;
            result.GTWA(nGTWA) = msg.data;
        case memsIDs.memsGTContext
            nGTContext = nGTContext+1;
            result.GTContext(nGTContext) = msg.data;
        case memsIDs.memsGTSteps
            nGTSteps = nGTSteps+1;
            result.GTSteps(nGTSteps) = msg.data;
        case memsIDs.memsGTDist
            nGTDist = nGTDist+1;
            result.GTDist(nGTDist) = msg.data;
        case memsIDs.memsGTUserHeading
            nGTUserHeading = nGTUserHeading+1;
            result.GTUserHeading(nGTUserHeading) = msg.data;
        case memsIDs.memsGTBodyPos
            nGTBodyPos = nGTBodyPos+1;
            result.GTBodyPos(nGTBodyPos) = msg.data;
            
            %NVm
        case memsIDs.memsAccCalNVM
            memsState = memsAccCalNVM(memsState, msg.data, msg.header.timestamp, memsState.logging);
        case memsIDs.memsGyrCalNVM
            memsState = memsGyrCalNVM(memsState, msg.data, msg.header.timestamp, memsState.logging);
        case memsIDs.memsMagCalNVM
            memsState = memsMagCalNVM(memsState, msg.data, msg.header.timestamp, memsState.logging);
        case memsIDs.memsFactoryCal
            memsState = memsFactoryCal(memsState, msg.data, msg.header.timestamp, memsState.logging);
    end
    
    tline = fgetl(fileID);
end
printOnScreen('Finishing processing', memsState.logging.verbose);
fclose(fileID);
end

function printOnScreen(msg, verbose)
if(verbose)
    disp(msg);
end
end