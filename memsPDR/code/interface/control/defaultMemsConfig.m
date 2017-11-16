function [ z ] = defaultMemsConfig()
%defaultMemsConfig default config for MEMS subcompoenent,
z = emptyMemsConfig;
z.nSens     = 4;
z.sensSrc   = 1;
z.sensorInfo(1).type        = 193;
z.sensorInfo(1).isDataCal   = 0;
z.sensorInfo(1).range       = 2;
z.sensorInfo(1).sample_ms   = 20;
z.sensorInfo(1).SF          = 0.000488;
z.sensorInfo(1).vendorName  = -1;

z.sensorInfo(1).type        = 194;
z.sensorInfo(1).isDataCal   = 0;
z.sensorInfo(1).range       = 2000;
z.sensorInfo(1).sample_ms   = 20;
z.sensorInfo(1).SF          = 0.061035;
z.sensorInfo(1).vendorName  = -1;

z.sensorInfo(1).type        = 195;
z.sensorInfo(1).isDataCal   = 0;
z.sensorInfo(1).range       = 4912;
z.sensorInfo(1).sample_ms   = 40;
z.sensorInfo(1).SF          = 0.00625;
z.sensorInfo(1).vendorName  = -1;

z.sensorInfo(1).type        = 100;
z.sensorInfo(1).isDataCal   = 0;
z.sensorInfo(1).range       = 110000;
z.sensorInfo(1).sample_ms   = 100;
z.sensorInfo(1).SF          = 1;
z.sensorInfo(1).vendorName  = -1;
end