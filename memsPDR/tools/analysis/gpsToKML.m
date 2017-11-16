function [LocData, SpeedData, BearingData]  = gpsToKML(varargin)
% this function read log file and return the data, you can either give file
% name or data directly after calling readLog function
% sensData = plotSensorData('fname', 'ST_Log.txt') or plotSensorData('data', data)
% you can also define which sensor to read, output will be in engineering
% unit
topdir  = './';
fname   = 'ST_PDR_Log.txt';
verbose = 0;
readOnlyMsgs = [10202];
data        = [];
dataDefine  = 0;
plotting    = 1;
LocData     = emptyMemsPos;
SpeedData   = emptySpeed;
BearingData = emptyHeading;

   
for n = 1:2:nargin
    switch varargin{n}
        %to set log file name
        case 'fname'
            fname = varargin{n+1};
            %to set top dir where file is stores
        case 'verbose'
            verbose = varargin{n+1};
        case 'topdir'
            topdir = varargin{n+1};
        case 'data'
            data = varargin{n+1};
            dataDefine = 1;
        otherwise
            error(['unknown arg: ' varargin{n}])
    end
end

if(~dataDefine)
    data = readLog('fname',fname,'verbose', verbose, 'topdir', topdir, 'readOnlyMsgs',readOnlyMsgs);
end

if(~isfield(data, 'locationHandler'))
    disp('No Loc data found');
    return;
end

nL = length(data.locationHandler);
for n = 1:nL
% LatLong = emptyLLA;
% LatLong.valid = data.locationHandler(n).data.loc.valid && data.locationHandler(n).data.loc.utcTime >0 ...
%     && data.locationHandler(1).data.loc.latCir>0;
% LatLong.lat = data.locationHandler(n).data.loc.latCir*(2*180/2^32);
% LatLong.lon = data.locationHandler(n).data.loc.lonCir*(2*180/2^32);
% LatLong.alt = data.locationHandler(n).data.loc.alt_cm/100;
LatLong = data.locationHandler(n).data.loc;
Speed   = data.locationHandler(n).data.speed_cm;
Heading = data.locationHandler(n).data.speed_cm;
LocData(n)      = LatLong;
SpeedData(n)    = Speed;
BearingData(n)  = Heading;
end

posToKML(LocData,'fname', 'loc.kml', 'color', 'y');