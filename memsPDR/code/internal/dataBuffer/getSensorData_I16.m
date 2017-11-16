function data = getSensorData_I16(databuffer, interval, nAxis, getRaw)
%get the sensor data for given interval
%in C, it is better to pass pointer only.
dataIndx = getProcDataIndx(databuffer.procBuffer, interval, databuffer.info.sample_ms);
data = emptyDataSeries_I16(dataIndx.N, nAxis);
data.t0 = dataIndx.t0;
invSF = 1/databuffer.info.SF;
if(getRaw)
    invSFx =  1/databuffer.cal.SF(1,1);
    invSFy =  1/databuffer.cal.SF(2,2);
    invSFz =  1/databuffer.cal.SF(3,3);
    for n = 1:dataIndx.N
        m = mod(dataIndx.startIndx-1 + n-1, databuffer.procBuffer.Nmax)+1;
        data.valid(n) = databuffer.procBuffer.valid(m);
        data.x(n) = round(invSF*(invSFx*databuffer.procBuffer.x(m)) + databuffer.cal.bias(1));
        if(nAxis==3)
            data.y(n) = round(invSF*(invSFy*databuffer.procBuffer.y(m)) + databuffer.cal.bias(2));
            data.z(n) = round(invSF*(invSFz*databuffer.procBuffer.z(m)) + databuffer.cal.bias(3));
        end
    end
else
    for n = 1:dataIndx.N
        m = mod(dataIndx.startIndx-1 + n-1, databuffer.procBuffer.Nmax)+1;
        data.valid(n) = databuffer.procBuffer.valid(m);
        data.x(n) = round(invSF*(databuffer.procBuffer.x(m)));
        if(nAxis==3)
            data.y(n) = round(invSF*(databuffer.procBuffer.y(m)));
            data.z(n) = round(invSF*(databuffer.procBuffer.z(m)));
        end
    end
end
end