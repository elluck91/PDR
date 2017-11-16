classdef algoConsts
    % All the constants used but not internals ones
    properties (Constant)
        % stride length model type
        default_SL_FIFO         = 5;
        default_SF_FIFO         = 7;
        default_data_window     = 3;
        default_gpsLen          = 80;
        default_heigth          = 185;
        
        walk_x0     = -97;
        walk_x      = 146;
        walk_x2     = -27;
    end
end
