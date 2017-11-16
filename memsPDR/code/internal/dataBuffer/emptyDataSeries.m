function z = emptyDataSeries(nL, nAxis)
%structure to hold engineering unit data
if(nAxis==1)
    z = empty1DDataSeries(nL);
else
    z = empty3DDataSeries(nL);
end
end

function z = empty3DDataSeries(nL)
z = struct('t0', 0, ...
    'N', nL, ...
    'valid', zeros(1, nL), ...
    'x', zeros(1,nL), ...
    'y', zeros(1,nL), ...
    'z',zeros(1,nL));
end

function z = empty1DDataSeries(nL)
z = struct('t0', 0, ... %U32
    'N', nL, ...        %U8/U16
    'valid', zeros(1, nL), ... %Bool 
    'x', zeros(1,nL)); % float
end