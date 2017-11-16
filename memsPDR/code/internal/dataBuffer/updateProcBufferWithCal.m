function dataBuff = updateProcBufferWithCal(dataBuff, newCal, logging)
%no need to update
if(dataBuff.procBuffer.N == 0 || dataBuff.procBuffer.Nmax == 0)
    dataBuff.cal =  newCal;
    return;
end

if(dataBuff.procBuffer.N == dataBuff.procBuffer.Nmax)
    procFirstIndx = mod(dataBuff.procBuffer.lastIndx, dataBuff.procBuffer.Nmax)+1;
else
    procFirstIndx = 1;
end

xSFRatio = newCal.SF(1,1)/dataBuff.cal.SF(1,1);
ySFRatio = newCal.SF(2,2)/dataBuff.cal.SF(2,2);
zSFRatio = newCal.SF(3,3)/dataBuff.cal.SF(3,3);

xBiasDiff = (newCal.bias(1) - dataBuff.cal.bias(1))*newCal.SF(1,1)*dataBuff.info.SF;
yBiasDiff = (newCal.bias(2) - dataBuff.cal.bias(2))*newCal.SF(2,2)*dataBuff.info.SF;
zBiasDiff = (newCal.bias(3) - dataBuff.cal.bias(3))*newCal.SF(3,3)*dataBuff.info.SF;

%no need to check valid flag
for n = 1:dataBuff.procBuffer.N
    indx = procFirstIndx + n - 1;
    if(indx> dataBuff.procBuffer.Nmax)
        indx = indx - dataBuff.procBuffer.Nmax;
    end
    dataBuff.procBuffer.x(indx) = xSFRatio*dataBuff.procBuffer.x(indx) - xBiasDiff;
    dataBuff.procBuffer.y(indx) = ySFRatio*dataBuff.procBuffer.y(indx) - yBiasDiff;
    dataBuff.procBuffer.z(indx) = zSFRatio*dataBuff.procBuffer.z(indx) - zBiasDiff;
end
dataBuff.cal =  newCal;
end