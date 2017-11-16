function tag = memsGetDeltaPos(refTag,newTag)
tag = emptyDeltaPos;

validBit = bitand(refTag.valid, newTag.valid);
tag.validEN = bitand(validBit, memsConsts.validEN)>0;
tag.validU =  bitand(validBit, memsConsts.validU)>0;

dt = newTag.t - refTag.t;

if(tag.validEN>0)
    tag.dE = newTag.E - refTag.E;
    tag.dN = newTag.N - refTag.N;
    dist_err = abs(newTag.conf.dist_err -  refTag.conf.dist_err);
    tag.conf.ang_deg = round(atan2(tag.dE, tag.dN)*memsConsts.rads2Degs);
    dHeadingErr =  abs(newTag.conf.totalYaw_err -  refTag.conf.totalYaw_err)*1000/dt;
    dHeadingErr = min(dHeadingErr, 180);
    %tag.conf.major_cm = abs(dist_err*cos(dHeadingErr*memsConsts.degs2Rads));
    %tag.conf.minor_cm = abs(dist_err*sin(dHeadingErr*memsConsts.degs2Rads));
    D = abs(newTag.N - refTag.N);
    %check this
    tag.conf.major_cm = round(dist_err);
    tag.conf.minor_cm = round(abs(D*sin(dHeadingErr*memsConsts.degs2Rads/2)));
    
    if(tag.conf.minor_cm > tag.conf.major_cm)
        major_cm = tag.conf.major_cm;
        tag.conf.major_cm = tag.conf.minor_cm;
        tag.conf.minor_cm = major_cm;
        tag.conf.ang_deg = tag.conf.ang_deg + 90;
    end
    tag.conf.ang_deg = mod(tag.conf.ang_deg,360);
end

if(tag.validU>0)
    tag.dU = newTag.U - refTag.U;
    tag.conf.alt_cm = abs(newTag.conf.vDist_err -  refTag.conf.vDist_err);
end

end