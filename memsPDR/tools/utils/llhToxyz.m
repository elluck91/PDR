function [X,Y,Z] = llhToxyz(lat,long, h) 
  % Convert lat, long, height in WGS84 to ECEF X,Y,Z
  % lat and long given in decimal degrees.
  % altitude should be given in meters
  lat = lat/180*pi; %converting to radians
  long = long/180*pi; %converting to radians
  a = 6378137.0; % earth semimajor axis in meters 
  f = 1/298.257223563; % reciprocal flattening 
  e2 = 2*f -f^2; % eccentricity squared 
 
  chi = sqrt(1-e2*(sin(lat)).^2); 
  X = (a./chi +h).*cos(lat).*cos(long); 
  Y = (a./chi +h).*cos(lat).*sin(long); 
  Z = (a*(1-e2)./chi + h).*sin(lat);
