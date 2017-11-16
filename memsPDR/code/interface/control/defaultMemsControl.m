function [ z ] = defaultMemsControl()
%DEFAULTMEMSCONTROL default control for MEMS subcompoenent, enable all
%components
z = emptymemsControl;
z.controlMask = 2^32-1;
end