function sensData = plotSensorData(varargin)
% this function read log file and return the data, you can either give file
% name or data directly after calling readLog function
% sensData = plotSensorData('fname', 'ST_Log.txt') or plotSensorData('data', data)
% you can also define which sensor to read, output will be in engineering unit

    topdir  = './';
    fname   = 'ST_PDR_Log.txt';
    verbose = 0;
    readOnlyMsgs = [10102,10201];
    data    = [];
    dataDefine = 0;
    plotting = 1;
    sensorType = [memsConsts.sensAccId, ...
                  memsConsts.sensGyrId, ...
                  memsConsts.sensMagId, ...
                  memsConsts.sensPressureId, ...
                  memsConsts.sensTemperatureId];

    for n = 1:2:nargin
        switch varargin{n}
            %to set log file name
            case 'fname'
                fname   = varargin{n+1};
                % to set top dir where the file is stored
            case 'verbose'
                verbose = varargin{n+1};
            case 'topdir'
                topdir  = varargin{n+1};
            case 'sensorType'
                sensorType  = varargin{n+1};
            case 'plotting'
                plotting    = varargin{n+1};
            case 'data'
                data    = varargin{n+1};
                dataDefine = 1;
            case 'readOnlyMsgs'
                readOnlyMsgs = varargin{n+1};
            otherwise
                error(['unknown arg: ' varargin{n}])
        end
    end

    if(~dataDefine)
        data = readLog('fname',fname,'verbose', verbose, 'topdir', topdir, 'readOnlyMsgs',readOnlyMsgs);
    end

    if(isempty(data.memsSensData) || isempty(data.memsConfig))
        error('No data or configuration found');
    end

    nL = length(data.memsSensData);
    accData = zeros(4,nL);
    gyrData = zeros(4,nL);
    magData = zeros(4,nL);
    pressureData = zeros(2,nL);

    accData(1,:)        = 2^64 -1;
    gyrData(1,:)        = 2^64 -1;
    magData(1,:)        = 2^64 -1;
    pressureData(1,:)   = 2^64 -1;

    nAcc    = 0;
    nGyr    = 0;
    nMag    = 0;
    nPress  = 0;

    h = waitbar(0,'Parsing LOG file - Sensors...');
    for n = 1:nL
        refT = data.memsSensData(n).data.timestamp;
        for m = 1:data.memsSensData(n).data.nSens
            id = data.memsSensData(n).data.data(m).type;
            match = find(sensorType == id);
            if(isempty(match) || ~match)
                continue;
            end
            switch id
                case memsConsts.sensAccId
                    L = data.memsSensData(n).data.data(m).N;
                    accData(1,nAcc+1:nAcc+L) =  [data.memsSensData(n).data.data(m).datablock.dt] + refT;
                    accData(2,nAcc+1:nAcc+L) =  [data.memsSensData(n).data.data(m).datablock.x];
                    accData(3,nAcc+1:nAcc+L) =  [data.memsSensData(n).data.data(m).datablock.y];
                    accData(4,nAcc+1:nAcc+L) =  [data.memsSensData(n).data.data(m).datablock.z];
                    nAcc = nAcc+L;
                case memsConsts.sensGyrId
                    L = data.memsSensData(n).data.data(m).N;
                    gyrData(1,nGyr+1:nGyr+L) =  [data.memsSensData(n).data.data(m).datablock.dt] + refT;
                    gyrData(2,nGyr+1:nGyr+L) =  [data.memsSensData(n).data.data(m).datablock.x];
                    gyrData(3,nGyr+1:nGyr+L) =  [data.memsSensData(n).data.data(m).datablock.y];
                    gyrData(4,nGyr+1:nGyr+L) =  [data.memsSensData(n).data.data(m).datablock.z];
                    nGyr = nGyr+L;
                case memsConsts.sensMagId
                    L = data.memsSensData(n).data.data(m).N;
                    magData(1,nMag+1:nMag+L) =  [data.memsSensData(n).data.data(m).datablock.dt] + refT;
                    magData(2,nMag+1:nMag+L) =  [data.memsSensData(n).data.data(m).datablock.x];
                    magData(3,nMag+1:nMag+L) =  [data.memsSensData(n).data.data(m).datablock.y];
                    magData(4,nMag+1:nMag+L) =  [data.memsSensData(n).data.data(m).datablock.z];
                    nMag = nMag+L;
                case memsConsts.sensPressureId
                    L = data.memsSensData(n).data.data(m).N;
                    pressureData(1,nPress+1:nPress+L) =  [data.memsSensData(n).data.data(m).datablock.dt] + refT;
                    pressureData(2,nPress+1:nPress+L) =  [data.memsSensData(n).data.data(m).datablock.x];
                    nPress = nPress+L;
            end
        end
        waitbar(n/nL, h, sprintf('Parsing LOG file - Sensors... %.1f %%',100*n/nL));
    end
    close(h);

    accData(:,nAcc+1:nL)        = [];
    gyrData(:,nGyr+1:nL)        = [];
    magData(:,nMag+1:nL)        = [];
    pressureData(:,nPress+1:nL) = [];

    tRef    = min([accData(1,:), gyrData(1,:), magData(1,:),pressureData(1,:)]);
    aIndx   = find([data.memsConfig.data.sensorInfo.type]==memsConsts.sensAccId);
    if(nAcc>0 && ~isempty(aIndx))
        sensData.acc = plotAccData(accData, data.memsConfig.data.sensorInfo(aIndx).SF,tRef,plotting);
    end

    gIndx = find([data.memsConfig.data.sensorInfo.type]==memsConsts.sensGyrId);
    if(nGyr>0 && ~isempty(gIndx))
        sensData.gyr = plotGyrData(gyrData, data.memsConfig.data.sensorInfo(gIndx).SF,tRef, plotting);
    end

    mIndx = find([data.memsConfig.data.sensorInfo.type]==memsConsts.sensMagId);
    if(nMag>0 && ~isempty(mIndx))
        sensData.mag = plotMagData(magData, data.memsConfig.data.sensorInfo(mIndx).SF,tRef, plotting);
    end

    pIndx = find([data.memsConfig.data.sensorInfo.type]==memsConsts.sensPressureId);
    if(nPress>0 && ~isempty(pIndx))
        sensData.pressure = plotPressureData(pressureData, data.memsConfig.data.sensorInfo(pIndx).SF,tRef, plotting);
    end

    if sum(readOnlyMsgs == 10510) > 0
        sensData.verticalContext = data.memsGTverticalContext.data.verticalContext;
    end
    
    if sum(readOnlyMsgs == 10504) > 0
        sensData.verticalContext = data.memsGTContext.data.context;
    end
end

function sample = plotAccData(data, SF,tRef, plotting)
sample.x = data(2,:)*SF;
sample.y = data(3,:)*SF;
sample.z = data(4,:)*SF;
sample.t = data(1,:);
if(plotting)
    figure;
    plot((sample.t-tRef)*1e-3, sample.x, 'r');hold on;
    plot((sample.t-tRef)*1e-3, sample.y, 'g');
    plot((sample.t-tRef)*1e-3, sample.z, 'b');
    title('Acceleroemter data')
    xlabel('Time(s)')
    ylabel('g')
    legend('x','y','z')
end
end

function sample = plotGyrData(data, SF,tRef, plotting)
sample.x = data(2,:)*SF;
sample.y = data(3,:)*SF;
sample.z = data(4,:)*SF;
sample.t = data(1,:);
if(plotting)
    figure;
    plot((sample.t-tRef)*1e-3, sample.x, 'r');hold on;
    plot((sample.t-tRef)*1e-3, sample.y, 'g');
    plot((sample.t-tRef)*1e-3, sample.z, 'b');
    title('Gyroscope data')
    xlabel('Time(s)')
    ylabel('dps')
    legend('x','y','z')
end
end

function sample = plotMagData(data, SF,tRef, plotting)
sample.x = data(2,:)*SF;
sample.y = data(3,:)*SF;
sample.z = data(4,:)*SF;
sample.t = data(1,:);
if(plotting)
    figure;
    plot((sample.t-tRef)*1e-3, sample.x, 'r');hold on;
    plot((sample.t-tRef)*1e-3, sample.y, 'g');
    plot((sample.t-tRef)*1e-3, sample.z, 'b');
    title('Magnetoemter data')
    xlabel('Time(s)')
    ylabel('\muTesla')
    legend('x','y','z')
end
end
function sample = plotPressureData(data, SF,tRef,plotting)
sample.x = data(2,:)*SF;
sample.t = data(1,:);
if(plotting)
    figure;
    plot((sample.t-tRef)*1e-3, sample.x, 'r');hold on;
    title('Pressure data')
    xlabel('Time(s)')
    ylabel('hBar')
    legend('x')
end
end