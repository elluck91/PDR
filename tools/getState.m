function [ subdata ] = getState( data )
%GETSTATE Given a structure of Filtered GPS,
%function returns a subset of the GPS data 
% with timestamp, distance, and error count
subdata = emptyLocState;
subdata.Timestamp = data.Time;
subdata.Distance = data.Odo;
subdata.Good_Data = data.Good_Data;
subdata.OK_Data = data.OK_Data;
subdata.Bad_Data = data.Bad_Data;
end

