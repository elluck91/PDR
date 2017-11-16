function GPSData = plotGPSData(varargin)
% this function read log file and return the data, you can either give file
% name or data directly after calling readLog function
% sensData = plotSensorData('fname', 'ST_Log.txt') or plotSensorData('data', data)
% you can also define which sensor to read, output will be in engineering unit

topdir  = './';
fname   = 'ST_PDR_Log.txt';
verbose = 0;
readOnlyMsgs = [10202];
data        = [];
dataDefine  = 0;

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
utcData     = zeros(1,nL);
locData     = zeros(3,nL);
posConf     = zeros(2,nL);
speedData   = zeros(2,nL);
headData    = zeros(2,nL);

locScale    = 360/2^32;

utcData(1,:)    = 2^64-1;
locData(1,:)    = 2^64-1;
speedData(1,:)  = 2^64-1;

h = waitbar(0,'Parsing LOG file - GNSS ...');
for n = 1:nL
    utcData(1,n)    = data.locationHandler(n).data.loc.utcTime;
    locData(1,n)    = data.locationHandler(n).data.loc.latCir*locScale;
    locData(2,n)    = data.locationHandler(n).data.loc.lonCir*locScale;
    locData(3,n)    = data.locationHandler(n).data.loc.alt_cm/100;
    posConf(1,n)    = max(data.locationHandler(n).data.loc.posConf.major_cm, data.locationHandler(n).data.loc.posConf.minor_cm)/100;
    posConf(2,n)    = data.locationHandler(n).data.Nsats;
    speedData(1,n)  = data.locationHandler(n).data.speed_cm.val/100;
    speedData(2,n)  = data.locationHandler(n).data.speed_cm.conf;
    headData(1,n)   = data.locationHandler(n).data.bearing_degs.val;
    headData(2,n)   = data.locationHandler(n).data.bearing_degs.conf;
    
    waitbar(n/nL, h, sprintf('Parsing LOG file - GNSS ... %.1f %%',100*n/nL));
end
close(h)

GPSData.locData.UTC         = utcData;
GPSData.locData.lat         = locData(1,:);
GPSData.locData.lon         = locData(2,:);
GPSData.locData.alt         = locData(3,:);
GPSData.locData.posConf     = posConf(1,:);
GPSData.locData.Nsats       = posConf(2,:);
GPSData.speedData.val       = speedData(1,:);
GPSData.speedData.conf      = speedData(2,:);
GPSData.headData.val        = headData(1,:);
GPSData.headData.conf       = headData(2,:);

