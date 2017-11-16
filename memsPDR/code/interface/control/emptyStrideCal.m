function z = emptyStrideCal
% EMPTYMEMSPOS Summary of this function goes here
%   structure to hold stride length related parameters
z = struct('refDist_cm', 0, ... %U16,reference distance travelled
    'Nsteps', 0, ...        %U16, number of steps walked
    'dT_s', 0, ...        %U16, total time spend
    'Context_Horiz', 0, ... % context of user (0-unknown, 1- stationary,2-walking)
    'infoSource', 0);  % source of information (GNSS-1, Manual-2) 