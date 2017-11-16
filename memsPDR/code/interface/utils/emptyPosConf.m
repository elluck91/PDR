function z = emptyPosConf()
%uncertainty structure
z = struct('major_cm', 0, ... %U16,uncertainty in major axis
    'minor_cm', 0, ...
    'alt_cm', 0, ...          %U16, in altitude cm
    'ang_deg',0);             %U8, heading (degs) of ellipse 
end