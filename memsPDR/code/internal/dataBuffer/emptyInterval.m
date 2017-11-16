function z = emptyInterval()
z = struct('valid', 0, ...
    'startTime', 0, ...   %data will be used from this time
    'endTime', 0, ...     %till this time data will be used 
    'borderEndTime',0);   % data present actually in buffer
end