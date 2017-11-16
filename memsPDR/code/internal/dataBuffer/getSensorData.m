function data = getSensorData(databuffer, interval, nAxis, getRaw)
%get the sensor data for given interval
%in C, it is better to pass pointer only.
dataIndx = getProcDataIndx(databuffer.procBuffer, interval, databuffer.info.sample_ms);
data = emptyDataSeries(dataIndx.N, nAxis);
data.t0 = dataIndx.t0;
if(getRaw)
    invSFx =  1/databuffer.cal.SF(1,1);
    invSFy =  1/databuffer.cal.SF(2,2);
    invSFz =  1/databuffer.cal.SF(3,3);
    for n = 1:dataIndx.N
        m = mod(dataIndx.startIndx-1+n-1, databuffer.procBuffer.Nmax)+1;
        data.valid(n) = databuffer.procBuffer.valid(m);
        data.x(n) = invSFx*databuffer.procBuffer.x(m) + databuffer.cal.bias(1)*databuffer.info.SF;
        if(nAxis==3)
            data.y(n) = invSFy*databuffer.procBuffer.y(m) + databuffer.cal.bias(2)*databuffer.info.SF;
            data.z(n) = invSFz*databuffer.procBuffer.z(m) + databuffer.cal.bias(3)*databuffer.info.SF;
        end
    end
else
    for n = 1:dataIndx.N
        m = mod(dataIndx.startIndx-1+n-1, databuffer.procBuffer.Nmax)+1;
        data.valid(n) = databuffer.procBuffer.valid(m);
        data.x(n) = databuffer.procBuffer.x(m);
        if(nAxis==3)
            data.y(n) = databuffer.procBuffer.y(m);
            data.z(n) = databuffer.procBuffer.z(m);
        end
    end
end
end