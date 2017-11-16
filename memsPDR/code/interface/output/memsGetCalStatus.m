function calStatus = memsGetCalStatus(memsState,sensorType,timestamp)
calInfo = memsGetCalInfo(memsState,sensorType,timestamp);
calStatus = calInfo.calStatus;
end