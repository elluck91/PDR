function [ memsStatedata ] = memsDataHandler(memsStatedata,data, timestamp, logging)
%memsDataHandler Summary of this function goes here
%   function to handle acq sensor measurements, this will simply put in circular buffer 
memsStatedata = updateAcqBuffer(memsStatedata,data, timestamp, logging);