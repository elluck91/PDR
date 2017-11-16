function writeLog(varargin)
%similar to readLog but for writting log file
topdir = './';
    fname = 'ST_PDR_Log.txt';
msgData = [];

for n = 1:2:nargin
    switch varargin{n}
        %to set log file name
        case 'fname'
            fname = varargin{n+1};
            %to set top dir where file is stores
        case 'data'
            msgData = varargin{n+1};
        case 'topdir'
            topdir = varargin{n+1};
       otherwise
            error(['unknown arg: ' varargin{n}])
    end
end

topdir = strtrim(topdir);
if(~exist(topdir,'dir'))
    error([topdir ' directory not found:exit']);
end

if (topdir(end) ~= '/' && topdir(end) ~= '\')
    topdir = [topdir '/'];
end

fid = fopen([topdir fname],'w');
if fid == -1
    error(['Could not open file for reading: ' fname]);
else
    disp('writing log file');
end

if (~isstruct(msgData))
    disp('data is not in correct msg format');
    return;
end

[fieldName, fieldOrder, sampleOrder] = getMsgInOrder(msgData);
for n = 1:length(fieldOrder)
    eval(['data = msgData.' fieldName{fieldOrder(n)} '(' num2str(sampleOrder(n)) ');']);
    writeLine(fid, data);
end

fclose(fid);
end

function [fieldName, fieldOrder, sampleOrder] = getMsgInOrder(msgData)
fieldName = fields(msgData);
t = [];
fieldOrder = [];
sampleOrder = [];
for n = 1:length(fieldName)
    eval(['head = [msgData.' fieldName{n} '.header];']);
    fieldOrder = [fieldOrder n*ones(1,length([head.timestamp]))];
    sampleOrder = [sampleOrder 1:length([head.timestamp])];
    t = [t [head.timestamp] + n*1E-10];
end
[~, sortIndx] =  sort(t);
fieldOrder = fieldOrder(sortIndx);
sampleOrder = sampleOrder(sortIndx);
end