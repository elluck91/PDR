function [ s ] = getDistance( point_one, point_two )
s = emptyDistErrState;
%GETDISTANCE Given two points, calculate the distance between them and
% returns a structure containing Distance, and Distance_error.
% Function assumes the data is collected every second, therefore the time 
% difference of 10 seconds indicates the summation of 10 errors between 
% two points.
%
% Points are supposed to be a structure (returned by getState() function) containing:
% Timestamp
% Distance
% Good_Data
% OK_Data
% Bad_Data

s.Distance = point_two.Distance - point_one.Distance;

Good_coefficient = 0.1;
OK_coefficient = 1;
Bad_coefficient = 5;

s.Distance_error = (point_two.Good_Data - point_one.Good_Data) * Good_coefficient + ...
    (point_two.OK_Data - point_one.OK_Data) * OK_coefficient + ...
    (point_two.Bad_Data - point_one.Bad_Data) * Bad_coefficient;

s.Cumulative_error = (point_two.Good_Data) * Good_coefficient + ...
    (point_two.OK_Data) * OK_coefficient + ...
    (point_two.Bad_Data) * Bad_coefficient;
end

