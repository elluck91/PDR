function res = runUnitTestAll(varargin)
%to run unit test vector from normal log file for data buffer
%input variable, either fileName or folder subbase [1,2,3,4,5,7] for folder
%Test01, Test02, etc. You can define destination folder otherwise it will
%store in memsPDR/logs/unitTest/dataBuffer. It will create
%this function will search log file in main folder and subfolder but not
%recursively

global MAIN_DIR
%topdir = sprintf('%s/logs/unitTest/', MAIN_DIR);
res = emptyUnitTestResults;
topdir = './';
logfilesAddress = [];
fileNameDefine = 0;

for n = 1:2:nargin
    switch varargin{n}
        %to set log file name
        case 'fname'
            fname = varargin{n+1};
            fileNameDefine = 1;
        case 'topdir'
            topdir = varargin{n+1};
        case ''
            %to set top dir where unit test file will be stores
    end
end

if(isempty(MAIN_DIR))
    disp('MAIN_DIR is empty please set MAIN_DIR');
    return;
end

if (topdir(end) ~= '/' && topdir(end) ~= '\')
    topdir = [topdir '/'];
end

if(~fileNameDefine)
    logfilesAddress = searchFile(topdir);
else
    logfilesAddress.dir = topdir;
    logfilesAddress.fname = fname;
    testList = [0];
end

for n = 1:length(logfilesAddress)
    logging = defaultLogging;
    logging.verbose = 0;
    disp(sprintf('Running Unit test in %s/%s', logfilesAddress(n).dir, logfilesAddress(n).fname));
    %disp(nameF);
    fileResults(n) = unitTestReplayer('topdir', logfilesAddress(n).dir, 'fname', logfilesAddress(n).fname, 'logging', logging);
    [res] = mergeRes(res, fileResults(n));
    [fieldOrder, resOrder] = getRes(fileResults(n));
    disp('Unit Test Results:  Pass | Fail')
    if(~isempty(resOrder))
        for k = 1:length(resOrder(:,1))
            disp([fieldOrder(k,:) ':  ' num2str(resOrder(k,1)) '   |   ' num2str(resOrder(k,2))])
        end
    end
end
if(n>1)
    [fieldOrder, resOrder] = getRes(res);
    disp('----Total Unit Test Results:  Pass | Fail -----')
    for k = 1:length(resOrder(:,1))
        disp([fieldOrder(k,:) ':  ' num2str(resOrder(k,1)) '   |   ' num2str(resOrder(k,2))])
    end
end
end

function lst = searchFile(topDir)
lst = [];
mainLst = dir(topDir);
if(isempty(mainLst))
    error('No folder or file found: exiting');
end
folderLst = mainLst([mainLst.isdir]==1);

fnames = ls([topDir, '/unitTest_*.txt']);
fL = 0;
if(~isempty(fnames))
    for n = 1:size(fnames,1)
        fL = fL+1;
        lst(fL).dir = topDir;
        lst(fL).fname = fnames(n,:);
    end
end
for n = 1:length(folderLst)
    if(strcmp(folderLst(n).name, '..') || strcmp(folderLst(n).name, '.'))
        continue;
    end
    fnames = ls([folderLst(n).name '/unitTest_*.txt']);
    if(isempty(fnames))
        disp(['Warning:No file found in ' folderLst(n).name]);
        continue;
    end
    for k = 1:size(fnames,1)
        fL = fL+1;
        lst(fL).dir = [topDir folderLst(n).name '/'];
        lst(fL).fname = fnames(k,:);
    end
end
if(fL ==0)
    error(['Warning:No file found in ' topDir]);
end
end

function [fieldOrder, resOrder] = getRes(msgData)
fieldName = fields(msgData);
fieldOrder = [];
resOrder = [];  k = 0;
for n = 1:length(fieldName)
    eval(['npass = [msgData.' fieldName{n} '.Npass];']);
    eval(['nfail = [msgData.' fieldName{n} '.Nfail];']);
    if(npass+nfail>0)
        k = k+1;
        fieldOrder = strvcat(fieldOrder, fieldName{n});
        resOrder(k, :) = [npass, nfail];
    end
end
end

function [res] = mergeRes(res, newRes)
fieldName = fields(res);
for n = 1:length(fieldName)
    eval(['npass = [newRes.' fieldName{n} '.Npass];']);
    eval(['nfail = [newRes.' fieldName{n} '.Nfail];']);
    eval(['[res.' fieldName{n} '.Npass] = [res.' fieldName{n} '.Npass] + npass;']);
    eval(['[res.' fieldName{n} '.Nfail] = [res.' fieldName{n} '.Nfail] + nfail;']);
end
end