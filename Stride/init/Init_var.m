function [ z ] = Init_var()
%   EMPTYACCCAL Summary of this function goes here
%   Detailed explaination goes here
z = struct('stepN',     def_stepN,    ...    
           'strideN',   def_strideN,  ...
           'userN',     def_userN,    ...
           'gpsN',      def_gpsN );         
end

function [ z ] = def_strideN()
%   EMPTYACCCAL Summary of this function goes here
%   Detailed explaination goes here
z = struct('SL_FIFO',       algoConsts.default_SL_FIFO,     ...
           'SF_FIFO',       algoConsts.default_SF_FIFO,     ...
           'SF_comp',       0,      ...
           'SL_comp',       0,      ...
           'walkModel',     walkModel);
end

function [ z ] = def_stepN()
%   EMPTYACCCAL Summary of this function goes here
%   Detailed explaination goes here
z = struct('data_window',       algoConsts.default_data_window,  ...
           'step_count',        0,      ...
           'step_old',          0,      ...
           'step_par',          0,      ...
           'dt_step',           0,      ...
           'dt_step_prec',      0,      ...
           'dt_peak',           0,      ...
           'dt_peak_prec',      0,      ...
           'value',             0,      ...
           'coeff_filt',        0.8,    ...
           'step2step_time',    [],     ...
           'step2step_time_buffer',     zeros(algoConsts.default_SF_FIFO,1),   ...
           't_step_old',        0,  ...
           't_step_curr',       0,  ...
           'partial_distance',  0,  ...
           'look_for_positive', 1,  ...
           'look_for_negative', 0,  ...
           'covered_distance',  0 );
end

function [ z ] = def_gpsN()
%   EMPTYACCCAL Summary of this function goes here
%   Detailed explaination goes here
z = struct('dt_GPS',        2,      ...
           'seg_len_GPS',   algoConsts.default_gpsLen,     ...
           'speed_meas',    0,      ...
           'speed_est_1',     0,      ...
           'speed_est_2',     0,      ...
           'posConf_curr',  0,      ...
           'heading_curr',  0,      ...
           'heading_est',   0,      ...
           'lat_est',       0,      ...
           'lon_est',       0);
end

function [ z ] = def_userN()
z = struct('User_heigth',       algoConsts.default_heigth);
end

function [ z ] = walkModel()
z = struct('walk_x0',       algoConsts.walk_x0,  ...
           'walk_x',        algoConsts.walk_x,  ...
           'walk_x2',       algoConsts.walk_x2);
end



