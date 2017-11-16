function z = createMsg(data, timestamp, msgId)
%UNTITLED Summary of this function goes here
%   function to create standard message format
z = emptyMessage();
z.header.id = msgId;
z.header.timestamp = timestamp;
z.data = data;
end