function [ z ] = emptyAccCalNVM
z = struct('infoType', -1,  ...%I8 0- for load, 1 for save
    'calTime_s', 0, ...%U32
    'calInfo', emptyCalInfoOP(3));
end