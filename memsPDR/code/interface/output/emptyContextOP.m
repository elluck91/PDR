function z = emptyContextOP()
z = struct('horizContext',emptyHorizContext, ...
    'altContext',emptyAltContext, ...
    'vehicleContext',emptyVehicleContext, ...
    'userContext',emptyUserContext);
end

function z = emptyHorizContext()
z = struct('context', memsConsts.horizContextUnknown, ...
    'conf_val', memsConsts.confidenceUnknown);
end

function z = emptyAltContext()
z = struct('context', memsConsts.altContextUnknown, ...
    'conf_val', memsConsts.confidenceUnknown);
end


function z = emptyVehicleContext()
z = struct('context', memsConsts.vehicleUnknown, ...
    'conf_val', memsConsts.confidenceUnknown);
end

function z = emptyUserContext()
z = struct('context', memsConsts.userContextUnknown, ...
    'conf_val', memsConsts.confidenceUnknown);
end