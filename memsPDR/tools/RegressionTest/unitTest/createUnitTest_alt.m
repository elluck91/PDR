function createUnitTest_alt(varargin)
%to create unit test vector from normal log file for data buffer
%input variable, either fileName or folder subbase [1,2,3,4,5,7] for folder
%Test01, Test02, etc. You can define destination folder otherwise it will
%store in memsPDR/logs/unitTest/alttude. It will create
%unitTest_altitude_xx.txt

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
    destdir = sprintf('%s/logs/unitTest/altitude/', MAIN_DIR);
end

if(~fileNameDefine)
    if(isempty(testList))
        testList = [1:3];
    end
    for n = 1:length(testList)
        logfilesAddress(n).dir = sprintf('%s/logs/performanceTest/altitude/Test%02d', MAIN_DIR, testList(n));
        logfilesAddress(n).fname = 'ST_PDR_Log.txt';
    end
else
    logfilesAddress.dir = './';
    logfilesAddress.fname = fname;
    testList = [0];
end
for n = 1:length(logfilesAddress)
    logFileName = sprintf('%s/unitTest_altitude_%02d.txt', destdir, testList(n));
    fileID = fopen(logFileName, 'w');
    if(fileID == -1)
        disp(['failed to open' logFileName]);
        continue;
    end
    logging = defaultLogging;
    logging.unitTestLogging.altitude = fileID;
    logging.unitTestLogging.memsControl = fileID;
    logging.verbose = 0;
    disp(sprintf('Creating Unit test -  unitTest_altitude_%02d.txt', testList(n)));
    %disp(nameF);
    memsControl = defaultMemsControl;
    memsControl.controlMask = memsConsts.enableAltContext;
    logReplayer('topdir', logfilesAddress(n).dir, 'memsControl', memsControl, 'fname', logfilesAddress(n).fname, 'logging', logging);
    if(fileID>-1)
        fclose(fileID);
    end
end
end