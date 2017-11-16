function z = emptyOrientationOP()
z = struct('t0',0, ... %starting time of 1st sample
    'N',0, ... % total no. of sample availale
    'valid',0, ... % valid or not
    'dt_ms', 0, ... %time diff bw 2 sample in ms
    'yaw',[], ... % YPR in degree*100
    'roll',[], ...
    'pitch',[], ...
    'yaw_conf',0, ... % YPR confidence in deg
    'roll_conf',0, ...
    'pitch_conf',0); %overall confidence on pitch
end