function heading = headingLLH(lt1,lng1,lt2,lng2)
%compute heading between 2 lat lon
lat1 = lt1*pi/180;
lat2 = lt2*pi/180;
long1 = lng1*pi/180;
long2 = lng2*pi/180;

dlong = long2-long1;
x = sin(dlong)*cos(lat2);
y = cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(dlong);
heading = atan2(x,y)*180/pi;