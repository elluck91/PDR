function z = emptyDataSeries_I16(nL, nAxis)
%structure to hold engineering unit data
if(nAxis==1)
    z = empty1DDataSeries_I16(nL);
else
    z = empty3DDataSeries_I16(nL);
end
end

function z = empty3DDataSeries_I16(nL)
z = struct('t0', 0, ...
    'N', nL, ...
    'valid', zeros(1, nL), ...
    'x', zeros(1,nL), ...
    'y', zeros(1,nL), ...
    'z',zeros(1,nL));
end

function z = empty1DDataSeries_I16(nL)
z = struct('t0', 0, ... %U32
    'N', nL, ...        %U8/U16
    'valid', zeros(1, nL), ... %Bool 
    'x', zeros(1,nL)); % I16
end