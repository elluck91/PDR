classdef dataBufferConsts
    %DATABUFFERCONSTS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant)
        %starting lag, we will not process this data at the start of app
        minimumLagAtStart_ms = 30; 
        
        %acq buffer
        maxAcqBufferLength_ms = 1200;
        
        %processing buffer
        maxProcBufferLength_ms = 1750;
        
        %maximum missing data for interpolation
        maxMissingDataLength = 4;
        
        %maximum difference bw sat buffer and proc buffer
        maxTimediff2Reset = 5000;
        
        %min rate
        defaultBaseRate_ms = 20;
        %sensor related constants
        nominalSamplePeriodAcc = 1;
        nominalSamplePeriodMag = 2;
        nominalSamplePeriodGyr = 1;
        nominalSamplePeriodPress = 5;
    end
end