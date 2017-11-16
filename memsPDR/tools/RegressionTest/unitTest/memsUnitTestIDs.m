classdef memsUnitTestIDs
    %memsUnitTestIDs Summary of this class goes here
    %   All messages id related to unit test are defined here
    
    properties (Constant)
        
        uUpdateProcBuffer = 10708;
        uUpdateAcqBuffer = 10709;
        
        %magModel
        uMagModel_setPosTime = 10711;
        uMagModel_getIGRFModel = 10712;
        uMagModel_getIGRFModel_vldt = 10713
        
        %carryPosition 
        uCarryPosition_state_before_update = 10715;
        uCarryPosition_state_after_update = 10716;
        
        %attitude
        uAttitude_updateAttitude = 10721;
        uAttitude_getAttitude = 10722;
        uAttitude_getAttitude_vldt = 10723;
        uAttitude_SetKnobs = 10724;
        
        %magnetoemeter cal
        uMagCal_state = 10730; %state
        uMagCal_state_vldt = 10731; %check the state
        
        %Accleroemeter cal
        uAccCal_state = 10733; %state
        uAccCal_state_vldt = 10734; %check the state
        
        %walking Angle 
        uWalkAngle_state = 10737; %state
        uWalkAngle_state_vldt = 10738; %check the state
        
        %alt
        uAlt_state = 10740; %state
        
        uDataAcc_info = 10750;
        uDataAcc_cal = 10751;
        uDataAcc_acqBuffer = 10752;
        uDataAcc_procBuffer = 10753;
        
        uDataGyr_info = 10755;
        uDataGyr_cal = 10756;
        uDataGyr_acqBuffer = 10757;
        uDataGyr_procBuffer = 10758;
        
        uDataMag_info = 10760;
        uDataMag_cal = 10761;
        uDataMag_acqBuffer = 10762;
        uDataMag_procBuffer = 10763;
        
        uDataPressure_info = 10765;
        uDataPressure_cal = 10766;
        uDataPressure_acqBuffer = 10767;
        uDataPressure_procBuffer = 10768;
        
        uDataAcc_info_vldt = 10800;
        uDataAcc_cal_vldt = 10801;
        uDataAcc_acqBuffer_vldt = 10802;
        uDataAcc_procBuffer_vldt = 10803;
        
        uDataGyr_info_vldt = 10805;
        uDataGyr_cal_vldt = 10806;
        uDataGyr_acqBuffer_vldt = 10807;
        uDataGyr_procBuffer_vldt = 10808;
        
        uDataMag_info_vldt = 10810;
        uDataMag_cal_vldt = 10811;
        uDataMag_acqBuffer_vldt = 10812;
        uDataMag_procBuffer_vldt = 10813;
        
        uDataPressure_info_vldt = 10815;
        uDataPressure_cal_vldt = 10816;
        uDataPressure_acqBuffer_vldt = 10817;
        uDataPressure_procBuffer_vldt = 10818;
        
        %step detection
        uStepState_NumberOfSteps = 10901;
    end
end