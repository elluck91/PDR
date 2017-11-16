function [ z ] = emptymemsControl()
%EMPTYMEMSCONTROL used to cofigure or control each submodule
z = struct('controlMask', memsConsts.INVALID); %U32, each bit is for each
%   %controlMask
%         enableAccCal  = 1;
%         enableGyroCal = 2;
%         enableMagCal = 4;
%         enableStepDetection = 8;
%         enablePDRContext = 16;
%         enableAltContext = 32;
%         enableStaticDetect = 64;
%         enableAttitude = 128;
%         enableWalkingAngle = 256;
%         enableStrideLengthLearning = 512; %bit 9
%         enablePDR = 2^31;
%submodule, check memsConsts
end