classdef stepConsts
    % all the constants used but not internal/local ones
    properties (Constant)
        % minSensors      = 2^(memsConsts.sensAccType-1);
        minSample_ms    = 50;       % minimum rate to run
        interval_ms     = 1000;     % schedule to run
        border_ms       = 50;       % delay in execution
        
        samplingRate    = 50;       % [Hz]
        
        % Energy related constants
        windowLength    = 100;
        overlap         = 50;
        
        minWalkingEnergy    = 0.01;
        upperLimitOnWalkingDuration     = 350;  %  7 sec x sampling rate
        upperLimitOnNotWalkingDuration  = 1500; % 30 sec x sampling rate
        
        normAccAutoCovWinSize       = 150;
        centerPeakRatioForNextPeak  = 0.15;
        leastConfidenceToKeepCurrentFilter = 2;
        searchWindowForAutoCovPeak  = 4;
        
        maxModelEnergy      = 5;
        minModelStepFreq    = 1;
        maxModelStepFreq    = 3;
        
        % Coefficients for EnergyBased Model of StepFreq
        p1  = -0.03015;
        p2  = 0.3618;
        p3  = -1.455;
        p4  = 2.459;
        p5  = 0.9559;
        
        maxAllowedErrorFromModel    = 0.2;
        maxAllowedErrorFromAutoCovPeak = 0.4;
        outOfModelMaxStepFreq   = 4;
        outOfModelMinStepFreq   = 2.5;
        maxFilterAStepFreq      = 1.7;
        maxFilterBStepFreq      = 2.2;
        maxFilterCStepFreq      = 2.8;

        
        % Filter related constants - different filters based on estimated speed 
        noOfFilters     = 5;
        DEFAULT = 1;    FILTER_A = 2;   FILTER_B = 3;   FILTER_C = 4;   FILTER_D = 5;
        filterBufferSize        = 9;
        diffSignalBufferSize    = 6;
        filterSettlingDuration  = 200;      % 4 seconds
        
        % Filter Coefficients
        % Coeff for default filter that works for most of normal walking
        % scenarios and carry positions
        aFiltDefault = [1,-7.46442015946155,24.5171161043615,-46.2785394976636,54.9076032093704,-41.9301505959120,20.1266362140158,-5.55226839964801,0.674024707627432];
        bFiltDefault = [2.67349042027724e-05,0,-0.000106939616811090,0,0.000160409425216634,0,-0.000106939616811090,0,2.67349042027724e-05];
        % Coeff for filter A for slow walking
        aFiltA = [1,-7.64893668322951,25.7160522677844,-49.6329385874114,60.1454635658898,-46.8596559441370,22.9226168310710,-6.43717436884077,0.794573764151023];
        bFiltA = [3.34425443125959e-06,0,-1.33770177250384e-05,0,2.00655265875576e-05,0,-1.33770177250384e-05,0,3.34425443125959e-06];
        % Coeff for filter B for fast walking
        aFiltB = [1,-7.63833569927061,25.7337952531301,-49.9363757760314,61.0394360491543,-48.1248701874494,23.9006306497082,-6.83688274227410,0.862610636496061];
        bFiltB = [5.94209696590259e-07,0,-2.37683878636104e-06,0,3.56525817954155e-06,0,-2.37683878636104e-06,0,5.94209696590259e-07];
        % Coeff for filter C for jogging/running
        aFiltC = [1,-7.28351649399376,23.5158235158547,-43.9395479733031,51.9573046461973,-39.8110512773123,19.3047120027864,-5.41770661404376,0.674024707627427];
        bFiltC = [2.67349040722110e-05,0,-0.000106939616288844,0,0.000160409424433266,0,-0.000106939616288844,0,2.67349040722110e-05];
        % Coeff for filter D for sprinting
        aFiltD = [1,-6.93524655989530,21.6270732579841,-39.5303630308591,46.2778868744189,-35.5220474034546,17.4637792560308,-5.03260435541903,0.652173123711935];
        bFiltD = [3.62696826475524e-05,0,-0.000145078730590209,0,0.000217618095885314,0,-0.000145078730590209,0,3.62696826475524e-05];
          
        N = 9; 
        
        % Step detection related thresholds
        p2pThresh   = 0.10;
        durationMinThresh   = floor(50/3.5/2);      % max freq in Hz 3.5
        durationMaxThresh   = ceil(50/0.8/2);       % min freq in Hz 0.8
        
        % peak detection related constants
        NEGATIVE_PEAK       = -1;
        POSITIVE_PEAK       = 1;
        minZoneDiffValue    = 0.02;
        
        % Step frequency related constants
        stepFrequencyMaxNoOfSteps       = 6;        % 3 strides
        stepFrequencyResetDuration      = 50;
        stepFrequencyMaxConfidence      = 5; 
        stepFrequencySamplingRate       = 50;
        minFreqThresh                   = 0.1;
        
        % Averaging filter related constants
        averagingFilteredWindow         = 5;
        averagingFilteredSearchWindow   = 50;
        stepFreqThreshForWindowSearch   = 2.1;      % 2.1 Hz
        
        % Step Event related constants
        searchDelaySinceLastStep    = 10;
        threshNegPeak   = 1.2;
        threshPosPeak   = 0.8;
        correctionDueToAveraging    = 4;
        maxDurationDifferenceBetweenClosePeaks  = 15
        minValueDifferenceBetweenClosePeaks     = 0.05;
        searchWindowForAvgFilteredPeak  = 2;
        STEP_EVENT_UPDATED              = -1;
        STEP_EVENT_TO_BE_UPDATED        = 0;
        
        % Results related constants
        stepResultBufferSize    = 10;
        % step detection average error pc
        stepError_pc    = 2;
        
        % Generic COnstants
        TRUE = 1; FALSE = 0;
    end
end
