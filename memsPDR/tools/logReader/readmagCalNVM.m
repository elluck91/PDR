function [data, isOk] = readmagCalNVM(fName)
data = [];
isOk = 0;
fileID = fopen(fName);
if(fileID == -1)
    disp('NVM- No file to read');
    return;
end
A = fread(fileID);
base = 1;
data.infoType = A(base); base = base+4;
data.infoType = 0 ;
disp('NVM- Change from write to read');
data.calTime_s = typecast(uint8(A(base:base+3)), 'uint32'); base = base+4;
data.calInfo = emptyCalInfoOP(3);
data.calInfo.calStatus = A(base); base = base+4; %enum size 32 signed int
data.calInfo.isDiagonal = A(base); base = base+4;
for n = 1:3
    data.calInfo.bias(n) = typecast(uint8(A(base:base+3)), 'single'); base = base+4;
end

for n = 1:3
    for m = 1:3
        data.calInfo.SF(n,m) = typecast(uint8(A(base:base+3)), 'single'); base = base+4;
    end
end

data.calHist = emptyCalHist(5);

data.calHist.N = A(base); base = base+1;
data.calHist.Nmax = A(base); base = base+3;

for n = 1:5
    %check fo next
    data.calHist.data(n).t = typecast(uint8(A(base:base+3)), 'uint32'); base = base+4;
    data.calHist.data(n).quality = A(base); base = base+1;
    data.calHist.data(n).qualitySF = A(base); base = base+1;
    data.calHist.data(n).bias(1) = typecast(uint8(A(base:base+1)), 'int16'); base = base+2;
    data.calHist.data(n).bias(2) = typecast(uint8(A(base:base+1)), 'int16'); base = base+2;
    data.calHist.data(n).bias(3) = typecast(uint8(A(base:base+1)), 'int16'); base = base+2;
    data.calHist.data(n).SF(1) = typecast(uint8(A(base:base+1)), 'uint16'); base = base+2;
    data.calHist.data(n).SF(2) = typecast(uint8(A(base:base+1)), 'uint16'); base = base+2;
    data.calHist.data(n).SF(3) = typecast(uint8(A(base:base+1)), 'uint16'); base = base+2;
    data.calHist.data(n).SFI(1) = typecast(uint8(A(base:base+1)), 'int16'); base = base+2;
    data.calHist.data(n).SFI(2) = typecast(uint8(A(base:base+1)), 'int16'); base = base+2;
    data.calHist.data(n).SFI(3) = typecast(uint8(A(base:base+1)), 'int16'); base = base+2;
end
fclose(fileID);
isOk = 1;
end