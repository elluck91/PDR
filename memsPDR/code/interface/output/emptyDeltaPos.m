function z = emptyDeltaPos()
z = struct('validEN', 0, ... %BOOL
    'validU', 0, ...         %BOOL
    'dE', 0, ...			%I16
    'dN', 0, ...			%I16
    'dU', 0, ...
    'conf', emptyPosConf);
end