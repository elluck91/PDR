function z = emptyUserHeadingOP()
z = struct('t',0, ... %exectuation time U32
    'valid',0, ... % valid or not     BOOL
    'heading',0, ... % YPR in degree  U16
    'heading_conf',0); % YPR Conf in degree U16
end