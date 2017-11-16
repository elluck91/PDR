function [ z ] = emptyMagCalNVM
z = struct('infoType', -1,  ...%I8
    'calTime_s', 0, ...%U32
    'calInfo', emptyCalInfoOP(3), ...
    'calHist', emptyCalHist(magCalConsts.NHist));
end