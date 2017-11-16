function [ z ] = emptyUserInfo()
%EMPTYUSERINFO Summary of this function goes here
%   to hold user infor
z = struct('height_cm', 0, ...      % U16
           'weight_kg', 0, ...      % U8.
           'age_year', 0, ...       % U8
           'gender', 0);            % enum
end