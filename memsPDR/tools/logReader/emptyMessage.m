function z = emptyMessage()
%generic message to hold data
z = struct('header',emptyMsgHeader, ...
           'data', struct(''));