function PerformanceTest_magCal(varargin)
%to check the perfromance test vector from normal log file for data buffer
%input variable, either fileName or folder subbase [1,2,3,4,5,7] for folder
%Test01, Test02, etc. You can define destination folder otherwise it will
%store in memsPDR/logs/performanceTest/magCal. It will create
%memsState.mat

global MAIN_DIR
destdir = [];  %to store unit test './'
fname = 'ST_PDR_Log.txt';
testList = [];
logfilesAddress = [];
fileNameDefine = 0;
replace = 0;

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
        case 'replace'
            replace =  varargin{n+1};
    end
end

if(isempty(MAIN_DIR))
    disp('MAIN_DIR is empty please set MAIN_DIR');
    return;
end

if(isempty(destdir))
    destdir = sprintf('%s/logs/performanceTest/magCal/', MAIN_DIR);
end

if(~fileNameDefine)
    if(isempty(testList))
        testList = 1:7;
    end
    for n = 1:length(testList)
        logfilesAddress(n).dir = sprintf('%s/logs/performanceTest/magCal/Test%02d', MAIN_DIR, testList(n));
        logfilesAddress(n).fname = 'ST_PDR_Log.txt';
    end
else
    logfilesAddress.dir = './';
    logfilesAddress.fname = fname;
    testList = 0;
end
for n = 1:length(logfilesAddress)
    logFileName = sprintf('%s/Test%02d/memsState.mat', destdir, testList(n));
    logging = defaultLogging;
    logging.dbgLogging.magCal =1;
    logging.verbose = 0;
    control = defaultMemsControl;
    control.controlMask = memsConsts.enableMagCal;
    disp(sprintf('Creating Perfromance test -  %02d', testList(n)));
    [~, memsCurrent] = logReplayer('topdir', logfilesAddress(n).dir, 'fname', logfilesAddress(n).fname, 'logging', logging);
    if(exist(logFileName))
        figure(testList(n));
        load(sprintf('%s/Test%02d/memsState.mat', destdir, testList(n)));
        CalRef = [memsStateRef.moduleState.magCal.dbg.calIn];
        tCalRef = [CalRef.t];
        biasRef = [CalRef.bias];
        subplot(2,1,1);plot(tCalRef, biasRef, '-o')
        subplot(2,1,2);plot(tCalRef, reshape([CalRef.SF], 3,[]), '-o')
        hold all;
        Cal = [memsCurrent.moduleState.magCal.dbg.calIn];
        tCal = [Cal.t];
        bias = [Cal.bias];
        subplot(2,1,1);hold all;plot(tCal, bias, '-*')
        subplot(2,1,2);hold all;plot(tCal, reshape([Cal.SF], 3,[]), '-*')
        pause(0.1);
        save(sprintf('%s/temp/memsState%02d.mat', destdir, testList(n)), 'memsCurrent');
    end
    if(replace)
        clear memsStateRef;
        memsStateRef = memsCurrent;
        save(logFileName, 'memsStateRef')
    end
end
end