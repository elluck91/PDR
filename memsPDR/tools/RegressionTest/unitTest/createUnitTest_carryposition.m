function createUnitTest_carryposition(varargin)

global MAIN_DIR

destdir = [];
fname = 'ST_PDR_Log.txt';
testList = [];
logfilesAddress = [];
fileNameDefine = 0;


for n=1:2:nargin
    switch varargin{n}
        %to set the log file name
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
    destdir = sprintf('%s/logs/unitTest/carryPos/', MAIN_DIR);
end

if(~fileNameDefine)
    if(isempty(testList))
        testList = [1];
    end
    for n = 1:length(testList)
        logfilesAddress(n).dir = sprintf('%s/logs/performanceTest/carryPos/Test%02d', MAIN_DIR, testList(n));
        logfilesAddress(n).fname = 'ST_PDR_Log.txt';
    end
else
    logfilesAddress.dir = './';
    logfilesAddress.fname = fname;
    testList = [0];
end

for n=1:length(logfilesAddress)
   logFileName = sprintf('%s/unitTest_carryPos_%02d.txt', destdir, testList(n));
    fileID = fopen(logFileName, 'w');
    if(fileID == -1)
        disp(['failed to open' logFileName]);
        continue;
    end
    logging = defaultLogging;
    logging.unitTestLogging.carryPos = fileID;
    logging.unitTestLogging.memsControl = fileID;
    logging.verbose = 0;
    disp(sprintf('Creating Unit test -  unitTest_carryPos_%02d.txt', testList(n)));
    %disp(nameF);
    memsControl = defaultMemsControl;
    memsControl.controlMask = memsConsts.enableCarryPos;
    logReplayer('topdir', logfilesAddress(n).dir, 'fname', logfilesAddress(n).fname, 'logging', logging);
    if(fileID>-1)
        fclose(fileID);
    end
end
end



















