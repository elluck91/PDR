function z = emptyTagOP()
z = struct('valid', 0, ...
    't', 0, ....
    'E', 0, ... %I32 in cm 
    'N', 0, ... %I32 in cm 
    'U', 0, ....%I32 in cm 
    'D',0, .... %U32 in cm, total dist 
    'uD',0, ... %U32 in cm, total dist in vertical 
    'nSteps', 0, ... %U32, total steps 
    'conf',emptyTotalConf); %confidence associated with heading, steps, vertical etc, currently filled with 0
end

function z = emptyTotalConf()
z = struct('dist_err', 0, ... % horizontal distance error, U16, let it flip, if error diff < 0, add U16
    'vDist_err', 0, ...     %vertical distance error, U16
    'totalYaw_err', 0); %can be struct or total cummulative, U16
end