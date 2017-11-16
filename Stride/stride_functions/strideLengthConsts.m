classdef strideLengthConsts < handle
    % All the constants used but not internals ones
    properties (Constant)
        % stride length model type
        defaultStrideModel       = 0;
        GPS_learningStrideModel  = 1;
        USER_learningStrideModel = 2;
        Calibrated_model         = 3;
        
        defaultHeight_cm        = 185;      % default model developed by this height
        minHeight_cm            = 135;
        defaultWeight_kg        = 75;
        defaultAge_year         = 30;
        defaultGender           = 1;
        
        defaultStride_cm        = 70;
        seg_len_GPS             = 100;       % [m]
        seg_time_GPS            = 40;       % [s]
        seg_step_GPS            = 70;
        
        % Calibration buffer
        max_sizeCal_buffer      = 10;
        
        % Walking model 
        walkModel_x2            = -27;      % -26.873, rounding, max error 0.1cm
        walkModel_x             = 146;      % 145.730
        walkModel_x0            = -97;      % -96.920
        minWalkStride_cm        = 20;
        maxWalkStride_cm        = 200;
        walkModelRSquare        = 1.8;      % in cm (norm with len, residual, not R2)
        
        % Switching frequency - from walking to running model
        freqRun_Hz              = 2.3;
        
        % Running Model 
        runModel_x2             = 65.592;
        runModel_x              = -131.271;
        runModel_x0             = 57.642;
        minRunStride_cm         = 70;
        maxRunStride_cm         = 250;
        runModelRSquare         = 6.7;      % in cm
        
        % Calibration related 
        offOnePoint_thres       = [5 30];       % [%]
        
        walkModel_coeff_thresholds  = [ strideLengthConsts.walkModel_x0*0.8    strideLengthConsts.walkModel_x0*1.20; ...
                                        strideLengthConsts.walkModel_x*0.85     strideLengthConsts.walkModel_x*1.15;  ...
                                        strideLengthConsts.walkModel_x2*0.9    strideLengthConsts.walkModel_x2*1.10];
                                    
        runModel_coeff_thresholds   = [ strideLengthConsts.runModel_x0*0.8    strideLengthConsts.runModel_x0*1.20; ...
                                        strideLengthConsts.runModel_x*0.85     strideLengthConsts.runModel_x*1.15;  ...
                                        strideLengthConsts.runModel_x2*0.9    strideLengthConsts.runModel_x2*1.10];
        
        % Input acceptance
        freq_std_thresh         = 0.65;
        
        % Residual Computation
        freqVec4Res      = 0.8:0.2:3;
        strideVec_walk   = strideLengthConsts.walkModel_x2*(strideLengthConsts.freqVec4Res.^2) + ...
                          strideLengthConsts.walkModel_x*(strideLengthConsts.freqVec4Res.^1) + ...
                          strideLengthConsts.walkModel_x0;
                      
        strideVec_run   = strideLengthConsts.runModel_x2*(strideLengthConsts.freqVec4Res.^2) + ...
                          strideLengthConsts.runModel_x*(strideLengthConsts.freqVec4Res.^1) + ...
                          strideLengthConsts.runModel_x0;
    end
       
end