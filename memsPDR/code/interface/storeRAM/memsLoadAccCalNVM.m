function state = memsLoadAccCalNVM(state, logging)
%this function is dependended on platform, in embedded platform, it is
%require to implment this in order to load mag cal info from NVM
[success, ~] = loadFromNVM();

if(~success)
    return;
end

state = memsAccCalNVM(state, data, timestamp, logging);
%log the message 10253 here
end

%this is dummy functino and in Matlab will alway return 0, but in embedded
%platform, this can give success and failure, this functino read the data
%from NVM and 
function [success, data] = loadFromNVM()
success = 0;
data = [];
end