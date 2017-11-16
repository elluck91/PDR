function [ state ] = createUserData(state, time, stepss, dist, Tseg, userHeigth)
% This function gnerates the learning user logs which the user is supposed
% to give to improve the accuracy of the step length calculation

% the hypothesis is that the user is recording more learning logs, by
% alterning walking phases to not moving phases

if state.userInfo.height_cm ~= userHeigth
    state = defaultStrideLength(emptyStrideLength);   % If UserData are varying (user is different), then reset the Sl state
    state.userInfo.height_cm = userHeigth;
end
    
Tin     = Tseg(1);
Tout    = Tseg(2);

state.manual_input.Dist_cm    = -dist(Tin) + dist(Tout);      % mandatory for the user in order to start the one point calibration
state.manual_input.Nsteps     = -stepss(Tin) + stepss(Tout);  % step number is computed or directly set by the user
state.manual_input.Time       = time(Tout) - time(Tin);       % automatically computed by the algorithm
state.manual_input.activity   = 0;                            % could be included or not by the user, so set 0

% if there's any input from user, set true the relative flag to update the
% estimation coefficients
if state.manual_input.Dist_cm ~= 0
    state.manual_input.flag = 1;
else
    state.manual_input.flag = 0;
end

state.model = 1;