function createUnitTest_IGRFmodel(varargin)
%to create unit test vector from normal log file for data buffer
%input variable, either fileName or folder subbase [1,2,3,4,5,7] for folder
%Test01, Test02, etc. You can define destination folder otherwise it will
%store in memsPDR/logs/unitTest/dataBuffer. It will create
%unitTest_dataBuffer_xx.txt

global MAIN_DIR
destdir = [];  %to store unit test './'
testList = [];
logfilesAddress = [];
fileNameDefine = 0;

for n = 1:2:nargin
    switch varargin{n}
        %to set log file name
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
    destdir = sprintf('%s/logs/unitTest/IGRFmodel/', MAIN_DIR);
end

 if(isempty(testList))
        testList = [1:16];
 end
    
sampleData = getSampleData;

for n = 1:length(testList)
    logFileName = sprintf('%s/unitTest_IGRFmodel_%02d.txt', destdir, testList(n));
    fileID = fopen(logFileName, 'w');
    if(fileID == -1)
        disp(['failed to open' logFileName]);
        continue;
    end
    logging = defaultLogging;
    logging.unitTestLogging.IGRFmodel = fileID;
    logging.verbose = 0;
    disp(sprintf('Creating Unit test -  unitTest_IGRFmodel_%02d.txt', testList(n)));
    [pos, magField] = getModelData(sampleData(n, :));
    writeLine(fileID, createMsg(pos,0, memsUnitTestIDs.uMagModel_setPosTime));
    writeLine(fileID, createMsg(magField,0, memsUnitTestIDs.uMagModel_getIGRFModel_vldt));
    if(fileID>-1)
        fclose(fileID);
    end
end
end

function TestData = getSampleData()
%UTC, ALT_KM, Lat, Lon, X_nT, Y_nT, Z_nT
TestData = [ ...
    1562067837, 100, 70.3, 30.8, 9545.4, 2583.7, 51187.5; ...
    1538940501, 100, 70.3, 30.8, 9565.5, 2560.8, 51165.6; ...
    1467397059, 1.042, 70.3, 30.8, 9983.0, 2745.6,53272; ...
    1536822296,9.144, -70.3, -30.8, 18889.0,-285.2,-33106.5;
    1536822296,9.144, 43.3669444, -30.133333333, 23147.0, -4255.6, 39463.9; ...
    1523118809,9.144, 43.3669444, -54.6025, 20720.6, -6383.1,44041.0; ...
    1517585540,1.3,48.123,16.123, 20912.4, 1541.5,43883.9; ...
    1574215092,1.3,48.123,16.123, 20926.5, 1627.6, 43942.8; ...
    1523118809, 0,43.3669444,-54.6025,20814.0  -6421.2  44233.3; ...
    1420148127,0, 0, 0, 27548.3,-2623.2,-15797.3; ...
    1577932757,0, 0, 0, 27538.1,-2285.5,-16216.7; ...
    1486201529,0,37.269444,-121.849444, 22761.8,5426.6,42064.8; ...
    1517758455,1, 45.4730556, 9.19, 22560.3,996.2,41651.1; ...
    1549315381,0.5, 51.4877778, -0.178055,19522.1,-86.8,44694.8; ...
    1575339037,0.5, 35.436944, 139.62, 30097.0, -3952.2,35324.0; ...
    1575339037,0.5, 37.853055, 145.075, 28784,-3631.1,36278.9];
end

function [pos, magField] = getModelData(data)
pos = emptyMemsPos;
magField = emptyMagField;

pos.valid = 1;
pos.utcTime = data(1)*1000;
pos.latCir = floor(data(3)*2^32/360);
pos.lonCir = floor(data(4)*2^32/360);
pos.alt_cm = floor(data(2)*1000*100);

magField.valid = 1;
magField.N_nT = round(data(5));
magField.E_nT = round(data(6));
magField.U_nT = round(-data(7));
end