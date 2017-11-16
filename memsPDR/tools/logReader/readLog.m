function [data] = readLog(varargin)
%this function read log file and return the data
%ex data = readLog('fname', ST_LOG_PDR.txt', 'topdir', 'C:/');

% topdir = './';
% fname = 'ST_PDR_Log.txt';
verbose = 0;
readOnlyMsgs = [];

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
        case 'readOnlyMsgs'
            readOnlyMsgs = varargin{n+1};
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

fileID = fopen([topdir fname],'r');
if fileID == -1
    error(['Could not open file for reading: ' fname]);
else
    disp('reading log file');
end

tline = fgetl(fileID);
idList = [];
fieldNames = [];
nSkip = 0;
data = [];
while ischar(tline)
    [msg, Ok] = readLine(tline,readOnlyMsgs);
    if(~Ok)
        if(verbose)
            disp(['Skipping ' tline ' line']);
        end
        nSkip = nSkip+1;
        tline = fgetl(fileID);
        continue;
    end
    match = find(idList==msg.header.id);
    if(isempty(match))
        fldName = getFieldName(msg.header.id);
        if(isempty(fldName))
            if(verbose)
                disp(['Skipping ' tline ' line']);
            end
            nSkip = nSkip+1;
            continue;
        end
        idList = [idList msg.header.id];
        fieldNames = strvcat(fieldNames, fldName);
        eval(['data.' fldName '(1) = msg;']);
    else
        eval(['data.' fieldNames(match,:) '(end+1) = msg;']);
    end
    tline = fgetl(fileID);
end
fclose(fileID);
end