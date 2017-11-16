function z = emptySensorInfo()
%struct to hold sensor related info
z = struct('type', 0, ...      %U8, sensor type
    'isDataCal', memsConsts.INVALID, ...   %Bool, is input data calibrated
    'range', 0, ...            %U16, dynamic range of data
    'sample_ms', 0, ...        %float, sample time interval
    'SF', 0, ...               %float, scale factor to convert
    'vendorName', []);         %string, name of sensor vendor
end