function tagToKML(tag, refLLA, varargin)
%refLLA should be in degree and m
if(isempty(refLLA))
    return;
    disp('No reference position');
end

if(isfield(tag, 'data'))
    tag = [tag.data];
end
locScale = 2^32/360;
for n = 1:length(tag)
    lla = denuTodllh(tag(n).E/100,tag(n).N/100,tag(n).U/100,refLLA);
    posFix(n) = emptyMemsPos;
    posFix(n).valid = lla.valid;
    posFix(n).latCir = round(lla.lat*locScale);
    posFix(n).lonCir = round(lla.lon*locScale);
    posFix(n).alt_cm = round(lla.alt*100);
    if(n>1)
        delPos = memsGetDeltaPos(tag(n-1),tag(n));
        posFix(n).posConf = delPos.conf;
    end
end

posToKML(posFix,varargin{:}, 'plotConf',1);