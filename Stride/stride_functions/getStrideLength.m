function stride = getStrideLength(state, steps)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

switch(state.model)
    case strideLengthConsts.defaultStrideModel
        [strideModel]   =  getDefaultStrideModel(state, steps);
    case strideLengthConsts.GPS_learningStrideModel
        [strideModel]   =  getLearningStrideModel(state, steps);
    case strideLengthConsts.USER_learningStrideModel
        [strideModel]   =  getLearningStrideModel(state, steps);
    case strideLengthConsts.Calibrated_model
        [strideModel]   =  getLearningStrideModel(state, steps);
end

stride  = evaluateStride(strideModel, steps);
end

function strideModel = getDefaultStrideModel(state, steps)
% based on frequency switch between different model, currently returning
% only walking
if(steps.freq < strideLengthConsts.freqRun_Hz)
    strideModel.x0      = strideLengthConsts.walkModel_x0;
    strideModel.x       = strideLengthConsts.walkModel_x;
    strideModel.x2      = strideLengthConsts.walkModel_x2;
    strideModel.minStride_cm    = strideLengthConsts.minWalkStride_cm;
    strideModel.maxStride_cm    = strideLengthConsts.maxWalkStride_cm;
    strideModel.rSquare         = strideLengthConsts.walkModelRSquare;
else
    strideModel.x0      = strideLengthConsts.runModel_x0;
    strideModel.x       = strideLengthConsts.runModel_x;
    strideModel.x2      =  strideLengthConsts.runModel_x2;
    strideModel.minStride_cm    = strideLengthConsts.minRunStride_cm;
    strideModel.maxStride_cm    = strideLengthConsts.maxRunStride_cm;
    strideModel.rSquare         = strideLengthConsts.runModelRSquare;
end

strideModel     = scaleUserModel(strideModel, state.userInfo);
end

function strideModel = getLearningStrideModel(state, steps)
% based on frequency switch between different model, currently returning
% only walking
if(steps.freq < strideLengthConsts.freqRun_Hz)
    strideModel.x0      = state.walkModel.x0;
    strideModel.x       = state.walkModel.x;
    strideModel.x2      = state.walkModel.x2;
    strideModel.minStride_cm    = state.walkModel.minStride_cm;
    strideModel.maxStride_cm    = state.walkModel.maxStride_cm;
    strideModel.rSquare         = state.walkModel.rSquare;
else
    strideModel.x0      = state.runningModel.x0;
    strideModel.x       = state.runningModel.x;
    strideModel.x2      = state.runningModel.x2;
    strideModel.minStride_cm    = state.runningModel.minStride_cm;
    strideModel.maxStride_cm    = state.runningModel.maxStride_cm;
    strideModel.rSquare         = state.runningModel.rSquare;
end

strideModel     = scaleUserModel(strideModel, state.userInfo);
end

% update model with user info
function strideModel = scaleUserModel(strideModel, userInfo)
scale   = userInfo.height_cm/strideLengthConsts.defaultHeight_cm;
if(scale < 0.5)
    scale   = 1;
elseif(userInfo.height_cm < strideLengthConsts.minHeight_cm)
    scale   = 0.9;
end
strideModel.x0  =  scale*strideModel.x0;
strideModel.x   =  scale*strideModel.x;
strideModel.x2  =  scale*strideModel.x2;
end

function stride = evaluateStride(model, step)
stride  = emptyStrideOP;
f_Hz    = step.freq;

if(f_Hz < 0.1)
    stride.L_cm     = strideLengthConsts.defaultStride_cm;
    stride.conf     = 30;
else
    stride.L_cm     = model.x0 + model.x*f_Hz + model.x2*(f_Hz^2);
    stride.L_cm     = min(stride.L_cm, model.maxStride_cm);
    stride.L_cm     = max(stride.L_cm, model.minStride_cm);
    stride.conf     = round(2*model.rSquare/stride.L_cm*100);
end
end