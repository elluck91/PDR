function sensData = plotProcSensorData(varargin)
%this function plot the sensor data which is in processing buffer
% sensData = plotProcSensorData('data', 'data')
% you can also define which sensor to read, output will be in engineering
% unit
data = [];
sensData = [];
plotting = 1;
sensorType = [memsConsts.sensAccId ...
    ,memsConsts.sensGyrId ...
    ,memsConsts.sensMagId ...
    %   ,memsConsts.sensPressureId ...
    %  ,memsConsts.sensTemperatureId ...
    ];

for n = 1:2:nargin
    switch varargin{n}
        case 'sensorType'
            sensorType = varargin{n+1};
        case 'plotting'
            plotting = varargin{n+1};
        case 'data'
            data = varargin{n+1};
    end
end

tRef = 2^64-1;
for n = sensorType
    switch(n)
        case memsConsts.sensAccId
            tRef = min(tRef, data.acc.procBuffer.t - (data.acc.procBuffer.N-1)* data.acc.info.sample_ms);
        case memsConsts.sensGyrId
            tRef = min(tRef, data.gyr.procBuffer.t - (data.gyr.procBuffer.N-1)* data.gyr.info.sample_ms);
        case memsConsts.sensMagId
            tRef = min(tRef, data.mag.procBuffer.t - (data.mag.procBuffer.N-1)* data.mag.info.sample_ms);
        case memsConsts.sensPressureId
            tRef = min(tRef, data.pressure.procBuffer.t - (data.pressure.procBuffer.N-1)* data.pressure.info.sample_ms);
    end
end

for n = sensorType
    switch(n)
        case memsConsts.sensAccId
            ploAlldata(data.acc.procBuffer, tRef, data.acc.info.sample_ms, plotting, n);
        case memsConsts.sensGyrId
            ploAlldata(data.gyr.procBuffer, tRef, data.gyr.info.sample_ms, plotting, n);
        case memsConsts.sensMagId
            ploAlldata(data.mag.procBuffer, tRef, data.mag.info.sample_ms, plotting, n);
        case memsConsts.sensPressureId
            ploAlldata(data.pressure.procBuffer, tRef, data.pressure.info.sample_ms, plotting, n);
    end
end

function sample = ploAlldata(data, tRef, dt, plotting, sensorType)
if(data.N==0)
    sample = [];
    return;
end
if(data.Nmax==data.N)
    startIndx = mod(data.lastIndx,data.Nmax)+1;
else
    startIndx = 1;
end
tStart = data.t - (data.N-1)*dt;
for n = 1:data.N
    k = mod(startIndx + n -2, data.Nmax)+1;
    sample.x(n) = data.x(k);
    if(sensorType== memsConsts.sensPressureId)
        continue;
    end
    sample.y(n) = data.y(k);
    sample.z(n) = data.z(k);
    sample.t(n) = tStart + (n-1)*dt;
end
if(plotting)
    figure;
    plot((sample.t-tRef), sample.x, 'r*');hold on;
    if(sensorType== memsConsts.sensPressureId)
        title(['Pressure data tRef =' num2str(tRef)])
        ylabel('hPa')
        xlabel('Time(ms)')
        legend('x')
        return;
    end
    plot((sample.t-tRef), sample.y, 'g*');
    plot((sample.t-tRef), sample.z, 'b*');
    switch(sensorType)
        case memsConsts.sensAccId
            title(['Acceleroemter data tRef =' num2str(tRef)])
            ylabel('g')
        case memsConsts.sensGyrId
            title(['Gyro data tRef =' num2str(tRef)])
            ylabel('dps')
        case memsConsts.sensMagId
            title(['Mag data tRef =' num2str(tRef)])
            ylabel('uT')
    end
    xlabel('Time(ms)')
    legend('x','y','z')
end