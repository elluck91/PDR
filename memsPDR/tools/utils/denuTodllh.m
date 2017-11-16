function LatLong = denuTodllh(E,N,U,llh0)
LatLong = emptyLLA;
%function to convert given E (m) N(m) and U(m) with respect to llh0 (deg, m) to lat long
e            = 0.081819190843;   % eccentricity
e2           = e^2;              % square of eccentricity
sphi         = sin(llh0.lat*memsConsts.degs2Rads);
cphi         = cos(llh0.lat*memsConsts.degs2Rads);
tempDistCal1 = sqrt(1 - e2*sphi^2);
tempDistCal2 = memsConsts.earthRadii_km*1000*(1-e2)/(tempDistCal1^3);
tempDistCal3 = memsConsts.earthRadii_km*1000/tempDistCal1;
LatLong.valid = 1;
LatLong.lat = llh0.lat + N/( (tempDistCal2 + U)*memsConsts.degs2Rads);
LatLong.lon = llh0.lon + E/( (tempDistCal3 + U)*cphi*memsConsts.degs2Rads);
LatLong.alt = llh0.alt + U;