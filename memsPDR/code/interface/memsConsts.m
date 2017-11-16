classdef memsConsts
    % all the constants used but not internals onces
    
    properties (Constant)
        %sensor type
        sensAccType = 1;
        sensGyrType = 2;
        sensMagType = 3;
        sensPressureType = 4;
        sensTemperatureType = 5;
        
        %mask on sensor id (sensorID & _MASK to get required info)
        AXIS_MASK       = 192;
        SENSORTYPE_MASK = 7;
        BIT_MASK        = 32;
        
        %sensor Id (0-2 sensor type, 5-data type (16/32 bit), 6-7 N-axis)
        sensAccId = 193;
        sensGyrId = 194;
        sensMagId = 195;
        sensPressureId = 100;
        sensTemperatureId = 69;
        
        %controlMask
        enableAccCal        = 1;
        enableGyroCal       = 2;
        enableMagCal        = 4;
        enableStepDetection = 8;
        enablePDRContext    = 16;
        enableAltContext    = 32;
        enableStaticDetect  = 64;
        enableAttitude      = 128;
        enableWalkingAngle  = 256;
        enableStrideLengthLearning = 512; %bit 9
        enableCarryPos      = 1024; %bit 10
        enablePDR           = 2^31;
        
        %context
        %pdr context
        horizContextUnknown = 0;
        horizContextWalking = 1;
        horizContextFastWalk= 2;
        horizContextJogging = 3;
        
        %vertical context
        altContextUnknown   = 0;
        altContextOnFloor   = 1;
        altContextUpDown    = 2;
        altContextStairs    = 3;
        altContextElevator  = 4;
        altContextEscalator = 5;
        
        %vehicle context
        vehicleUnknown    = 0;
        vehicleStationary = 1;
        vehicleMoving     = 2;
        
        %bodypos (it is possible we will combine multiple in single)
        bodyUnknown     = 0;
        bodyOnDesk      = 1;
        bodyInHand      = 2;
        bodyNearHead    = 3;
        bodyShirtPocket = 4;
        bodyTrouserPocket = 5;
        bodyArmSwing    = 6;
        bodyJacketPocket = 7;
        
        %Usercontext
        userContextUnknown = 0;
        userContextPedestrain = 1;
        userContextVehicle = 2;
        userContextCycle = 3;
        
        %init
        memsInitDisable = 0;
        memsInitEnable = 1;
        
        %gender
        userGenderUnknown = 0;
        userGenderMale = 1;
        userGenderFemale = 2;
        
        %position source
        posSourceUnknown = 0;
        posSourceGNSS = 1;
        posSourceManual = 2;
        
        %confidence
        confidenceHigh = 3;
        confidenceMed = 2;
        confidencePoor = 1;
        confidenceUnknown = 0;
        
        %cal
        calQStatusUnknown = 0;
        calQStatusPoor = 1;
        calQStatusOk = 2;
        calQStatusGood = 3;
        
        %device source
        deviceSourceUnknow = 0;
        deviceSourceExt = 1; %on phone
        deviceSourceNative = 2; %on platform
        
        %valid bit in tag valid
        validD = 2; %1st
        validU = 4; %2
        validEN = 8; %3
        
        INVALID = -1;
        rads2Degs = 180/pi;
        degs2Rads = pi/180;
        earthRadii_km = 6371.009;
        earthRadiiMajor_km = 6378.137;
        earthRadiiMinor_km = 6356.752; 
        
         %this parameters is to control type of soft iron matrix and to use
        %soft iron compensation
        MAGCALUSE_SFTIRON = 0; %if you want to you use soft iron compensation
        MAGCALIS_SFTIRON_MATSYM = 0; %if soft iron matrix symmetric or asym
    end
end