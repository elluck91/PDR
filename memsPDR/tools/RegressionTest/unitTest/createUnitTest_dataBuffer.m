function createUnitTest_dataBuffer(varargin)
%to create unit test vector from normal log file for data buffer
%input variable, either fileName or folder subbase [1,2,3,4,5,7] for folder
%Test01, Test02, etc. You can define destination folder otherwise it will
%store in memsPDR/logs/unitTest/dataBuffer. It will create
%unitTest_dataBuffer_xx.txt

global MAIN_DIR
destdir = [];  %to store unit test './'
fname = 'ST_PDR_Log.txt';
testList = [];
logfilesAddress = [];
fileNameDefine = 0;

for n = 1:2:nargin
    switch varargin{n}
        %to set log file name
        case 'fname'
            fname = varargin{n+1};
            fileNameDefine = 1;
            %to set top dir where unit test file will be stores
        case 'destdir'
            destdir = varargin{n+1};
        case 'testList'
            testList = varargin{n+1};
    end
end

if(isempty(MAIN_DIR))
    disp('MAIN_DIR is empty please set MAIN_DIR');
    return;
end

if(isempty(destdir))
    destdir = sprintf('%s/logs/unitTest/dataBuffer/', MAIN_DIR);
end

if(~fileNameDefine)
    if(isempty(testList))
        testList = [1:5];
    end
    for n = 1:length(testList)
        logfilesAddress(n).dir = sprintf('%s/logs/performanceTest/dataBuffer/test%02d', MAIN_DIR, testList(n));
        logfilesAddress(n).fname = 'ST_PDR_Log.txt';
    end
else
    logfilesAddress.dir = './';
    logfilesAddress.fname = fname;
    testList = [0];
end
for n = 1:length(logfilesAddress)
    logFileName = sprintf('%s/unitTest_dataBuffer_%02d.txt', destdir, testList(n));
    fileID = fopen(logFileName, 'w');
    if(fileID == -1)
        disp(['failed to open' logFileName]);
        continue;
    end
    logging = defaultLogging;
    logging.unitTestLogging.dataBuffer = fileID;
    logging.unitTestLogging.memsControl = fileID;
    logging.unitTestLogging.memsConfig = fileID;
    logging.verbose = 0;
    control = defaultMemsControl;
    control.controlMask = bitor(memsConsts.enableAccCal, memsConsts.enableMagCal);
    disp(sprintf('Creating Unit test -  unitTest_dataBuffer_%02d.txt', testList(n)));
    %disp(nameF);
    logReplayer('topdir', logfilesAddress(n).dir, 'fname', logfilesAddress(n).fname, 'logging', logging, 'memsControl', control);
    if(fileID>-1)
        fclose(fileID);
    end
end
end