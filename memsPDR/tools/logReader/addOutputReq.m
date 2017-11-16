function data = addOutputReq(varargin)
%this function read log file and return the data, you can either give file
%name or data directly after calling readLog function
% sensData = plotSensorData('fname', 'ST_Log.txt') or plotSensorData('data', data)
% you can also define which sensor to read, output will be in engineering
% unit
topdir = './';
fname = 'ST_PDR_Log.txt';
fOutname = fname;
reqMsgID = [memsIDs.memsGetTag,memsIDs.memsGetStep, memsIDs.memsGetSpeed];
data.memsSensData = [];
dataDefine = 0;
loadNVM = 0;
nvmFile = 'mag_calibration.mcf';
for n = 1:2:nargin
    switch varargin{n}
        %to set log file name
        case 'fname'
            fname = varargin{n+1};
        case 'fOutname'
            fOutname = varargin{n+1};
        case 'verbose'
            verbose = varargin{n+1};
        case 'topdir'
            topdir = varargin{n+1};
        case 'reqMsgID'
            reqMsgID = varargin{n+1};
        case 'data'
            data = varargin{n+1};
            dataDefine = 1;
        case 'loadNVM'
            loadNVM = varargin{n+1};
        otherwise
            error(['unknown arg: ' varargin{n}])
    end
end

topdir = strtrim(topdir);
if (topdir(end) ~= '/' && topdir(end) ~= '\')
    topdir = [topdir '/'];
end

if(~dataDefine)
    data = readLog('fname',fname, 'topdir', topdir);
    if(strcmp(strtrim(fOutname), strtrim(fname)))
       disp('Overriding the file');
    end
end

if(isempty(data.memsSensData))
    error('No data or configuration found');
end

%get the interval
interval(1) = data.memsSensData(1).header.timestamp;
x = [data.memsSensData.header];
interval(2) = max([x.timestamp]);

%too long, ask user to choose to continue or not
if((interval(2)-interval(1))/1000 > 1e4)
    disp('addOutputReq: Too Long interval ?');
    tStr = input('Shall we proceed? Y/N [Y]:');
    if isempty(tStr)
        tStr = 'N';
    end
    if(strcmpi(tStr, 'N'))
        return;
    end
end

for n = 1:length(reqMsgID)
    fldName = getFieldName(reqMsgID(n));
    if(isempty(fldName))
        disp(['no match found for request ID: ' num2str(reqMsgID(n))]);
    else
        eval(['data.' fldName ' = createReq(reqMsgID(n), interval);']);
    end
end

if(loadNVM==1)
    [nvmData, isOk] = readmagCalNVM([topdir nvmFile]);
    if(isOk==1)
        nvmMsg = emptyMessage;
        nvmMsg.header.id = 10253;
        nvmMsg.header.timestamp = data.memsInit(1).header.timestamp+1;
        nvmMsg.data = nvmData;
        data.memsMagCalNVM = nvmMsg;
    end
end

writeLog('data', data, 'fname',fOutname, 'topdir', topdir);
end

function req = createReq(msgId, interval)
z = emptyMessage;
z.header.id = msgId;
L = floor((interval(2)-interval(1))/1000);
for n = 1:L
    req(n) = z;
    req(n).header.timestamp = interval(1) + n*1000; % after sensor
end
end