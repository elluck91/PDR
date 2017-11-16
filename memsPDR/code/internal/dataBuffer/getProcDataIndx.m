function dataIndx = getProcDataIndx(data, interval, dt)
%function to get data index for given interval
dataIndx = emptyProcIndx;
if(~interval.valid || data.Nmax==0 || data.N ==0 || dt == 0)
    return;
end

if(data.Nmax==data.N)
    startIndx = mod(data.lastIndx,data.Nmax)+1;
else
    startIndx = 1;
end
startTime = data.t - (data.N-1)*dt;

%dataIndx.startIndx = mod(startIndx + max(ceil((interval.startTime + 1E-3 - startTime)/dt),0)-1, data.Nmax)+1;
%lastSample = mod(data.lastIndx - max(floor((data.t - interval.endTime-1E-3)/dt),0) -1,data.Nmax)+1;

%(start,end] and it shuoldnt be [Start,end] since Start=lastEnd will make to use last sample twice 
dataIndx.startIndx = mod(startIndx + max(ceil((interval.startTime + 1E-3 - startTime)/dt),0)-1, data.Nmax)+1;
lastSample = mod(data.lastIndx - max(ceil((data.t - interval.endTime-1E-3)/dt),0) -1,data.Nmax)+1;
dataIndx.N = mod(lastSample- dataIndx.startIndx,data.Nmax)+1;
dataIndx.Nmax = data.Nmax;
deltaSample = (dataIndx.startIndx-startIndx);
if(deltaSample<0)
    deltaSample = dataIndx.Nmax + deltaSample;
end
dataIndx.t0 = startTime + deltaSample*dt; 
end

function z = emptyProcIndx()
z = struct('t0', 0, ... %starting sample time
    'N',0, ...  %total sample
    'startIndx',0, ... % first sample index in proc buffer
    'Nmax',0);  %max no.
end