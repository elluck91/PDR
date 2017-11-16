function z = emptyStepOP()
z = struct('tLastStep', 0, ... %U32
    'stepCount', 0, ... %U32
    'step_conf', 0); %U16
end