function [e,n,u] = xyzToenu(Xr, Yr, Zr, X, Y, Z) 
  % convert ECEF coordinates to local east, north, up 
 
  phiP = atan2(Zr,sqrt(Xr^2 + Yr^2)); 
  lambda = atan2(Yr,Xr); 
 
  e = -sin(lambda).*(X-Xr) + cos(lambda).*(Y-Yr); 
  n = -sin(phiP).*cos(lambda).*(X-Xr) - sin(phiP).*sin(lambda).*(Y-Yr) + cos(phiP).*(Z-Zr); 
  u = cos(phiP).*cos(lambda).*(X-Xr) + cos(phiP).*sin(lambda).*(Y-Yr) + sin(phiP).*(Z-Zr);
