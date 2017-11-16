function tag = memsGetTag(memsState,timestamp)
tag = emptyTagOP;
tag = memsState.moduleState.pdrOutput.refTag;
%return;

tag.t = timestamp;
timestamp = mod(timestamp, 2^32-1);
timestamp = memsGetLatestTime(memsState.data);
tag.t = timestamp;

%TODO
%make sure the timestamp is runnig ahead of tag timestamp
dt = timestamp - memsState.moduleState.pdrOutput.refTag.t - pdrOutputConsts.minOperatingLag_ms;
%subtracting minops will always make estimation behind by this time (remove
%this iff we able to reduce the delay in steps detection)
%too much forward or backward, no interpolation
if(abs(dt)>pdrOutputConsts.delayHold_ms || memsState.moduleState.pdrOutput.refTag.valid==0)
    tag.valid = 0;
    return;
end

if(abs(dt)> pdrOutputConsts.maxInterpolation_ms)
    alpha = 1;
else
    alpha = dt/pdrOutputConsts.maxInterpolation_ms;
end

if(bitand(tag.valid, memsConsts.validD))
    tag.D = tag.D + memsState.moduleState.pdrOutput.speed.speed_cm*alpha;
    tag.conf.dist_err = tag.conf.dist_err +  round(memsState.moduleState.pdrOutput.speed.speed_conf*alpha);
end

heading = memsState.moduleState.pdrOutput.heading.heading*memsConsts.degs2Rads;
if(bitand(tag.valid, memsConsts.validEN))
    tag.E = tag.E + sin(heading)*memsState.moduleState.pdrOutput.speed.speed_cm*alpha;
    tag.N = tag.N + cos(heading)*memsState.moduleState.pdrOutput.speed.speed_cm*alpha;
    tag.conf.totalYaw_err = tag.conf.totalYaw_err +  round(memsState.moduleState.pdrOutput.heading.heading_conf*alpha);
end

%     'U', 0, ....%I32 in cm
%     'uD',0, ... %U32 in cm, total dist in vertical
end

function endTime = memsGetLatestTime(data)
endTime =0;
if(data.acc.procBuffer.N > 0)
    endTime = max(data.acc.procBuffer.t, endTime);
end
if(data.gyr.procBuffer.N > 0)
    endTime = max(data.gyr.procBuffer.t, endTime);
end
if(data.mag.procBuffer.N > 0)
    endTime = max(data.mag.procBuffer.t,endTime);
    
end
if(data.pressure.procBuffer.N > 0)
    endTime = max(data.pressure.procBuffer.t,endTime);
end
if(endTime ==2^64-1)
    endTime = 0;
end
end