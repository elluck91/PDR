function  [ state ] = defaultStrideLength(state)
%   EMPTYACCCAL Summary of this function goes here
%   Detailed explaination goes here
state.model         = strideLengthConsts.defaultStrideModel;  % 0 – No learning, 1 – Use GPS, 2 – Use Manual input, 3- Calibrated
state.walkModel     = walkStrideModel;
state.runningModel  = runStrideModel;
state.userInfo      = defaultUserInfo;
state.manual_input  = defaultManualInput;
% state.dbg           = defaultStrideDebug;
end

function  z = walkStrideModel()
z = struct('x0',            strideLengthConsts.walkModel_x0,     ...     % constant
           'x',             strideLengthConsts.walkModel_x,      ...     % linear
           'x2',            strideLengthConsts.walkModel_x2,     ...     % quadratic
           'minStride_cm',  strideLengthConsts.minWalkStride_cm, ...     % min stride for ths model
           'maxStride_cm',  strideLengthConsts.maxWalkStride_cm, ...     % max Stride for this model
           'rSquare',       strideLengthConsts.walkModelRSquare);        % fitting of model with cal data
end

function  z = runStrideModel()
z = struct('x0',            strideLengthConsts.runModel_x0,      ...     % constant
           'x',             strideLengthConsts.runModel_x,       ...     % linear
           'x2',            strideLengthConsts.runModel_x2,      ...     % quadratic
           'minStride_cm',  strideLengthConsts.minRunStride_cm,  ...     % min stride for ths model
           'maxStride_cm',  strideLengthConsts.maxRunStride_cm,  ...     % max Stride for this model
           'rSquare',       strideLengthConsts.runModelRSquare); 
end

function  z = defaultUserInfo()
z = struct('height_cm',     strideLengthConsts.defaultHeight_cm, ...      % U16
           'weight_kg',     strideLengthConsts.defaultWeight_kg, ...      % U8.
           'age_year',      strideLengthConsts.defaultAge_year,  ...      % U8
           'gender',        strideLengthConsts.defaultGender);            % enum
end

function [ z ] = defaultManualInput()
%EMPTYACCCAL Summary of this function goes here
%   Detailed explanation goes here
z = struct('Dist_cm',       75,    ...
           'Time',          55,    ...
           'Nsteps',        100,   ...
           'flag',          0,     ... 
           'activity',      1);
end