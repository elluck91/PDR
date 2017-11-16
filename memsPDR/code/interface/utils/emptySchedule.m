function [ z ] = emptySchedule()
%EMPTYMEMSCONFIG to configure each sensors
%
z = struct('enable', 0, ... %if its enable or not
    'lastTime', 0, ...      %last data processed
    'interval_ms', 0,...    %minimum time to reschedule
    'border_ms', 0, ...     %delay in execution       
    'sensors', memsConsts.INVALID); %sensor required
end