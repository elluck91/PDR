classdef memsIDs
    % all the messages IDs which will be logged in log files,
    %these are standard messages ID not for debug (there is another files to do that)
    
    properties (Constant)
        %Message/Function for MEMS settings
        memsSetPhoneInfo = 10001;
        memsSetLoc = 10002;
        memsSetUserInfo = 10003;
        memsSetStrideCal = 10004;
       
        memsAttSetKnobs = 10005;
       
        %Message/Function for MEMS control
        memsInit = 10101;
        memsConfig = 10102;
        memsControl = 10103;
        memsReset = 10104;
        
        %Message/Function for MEMS Request
        memsGetSysStatus = 10401;
        memsGetTag = 10402;
        memsGetStep = 10403;
        memsGetStride = 10404;
        memsGetSpeed = 10405;
        memsGetCalInfo = 10406;
        memsGetCalStatus = 10407;
        memsGetOrientation = 10408;
        memsGetContext = 10409;
        memsGetCarryPos = 10410;
        memsGetUserHeading = 10411;
        %Message/Function for output
        %memsDPos
        %memsDDist
        %memsDStep
        
        %Message/Function for input
        memsSensData = 10201;
        locationHandler = 10202;
        
        memsFactoryCal = 10250; % to set factory cal param
        %MEssage for NVM
        memsAccCalNVM = 10251;
        memsGyrCalNVM = 10252;
        memsMagCalNVM = 10253;
        
        %messages for output results
        memsStatus = 10451;
        memsTag = 10452;
        memsStep = 10453;
        memsStride = 10454;
        memsSpeed = 10455;
        memsCalInfo = 10456;
        memsCalStatus = 10457;
        memsOrientation = 10458;
        memsContext = 10459;
        memsCarryPos = 10460;
        memsUserHeading = 10461;
        
        %Message/Function for ground truth
        memsGTLoc = 10501;
        memsGTYPR = 10502;
        memsGTWA = 10503;
        memsGTContext = 10504;
        memsGTSteps = 10505;
        memsGTDist = 10506;
        memsGTUserHeading = 10507;
        memsGTBodyPos = 10508;
        memsGTverticalContext = 10510;
    end
end