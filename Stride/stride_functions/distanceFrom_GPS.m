function [stateN, time_GPS ] = distanceFrom_GPS(stateN, samp_curr, time_sens, time_GPS, LAT, LON, speed, posConf, heading)

if  time_sens(samp_curr) >= time_GPS(stateN.gpsN.dt_GPS)   % when new GPS info are available
    pos_old     = [LAT(stateN.gpsN.dt_GPS - 1) LON(stateN.gpsN.dt_GPS - 1)];
    pos_curr    = [LAT(stateN.gpsN.dt_GPS) LON(stateN.gpsN.dt_GPS)];
    
    % Compute distance of the segment from the old recorded GPS position to the current one
    [d1, ~, ~]    = ll_dist_m(pos_old, pos_curr);
    
    d1f = d1;
    if stateN.gpsN.dt_GPS > 4
        pos_old_filt = [LAT(stateN.gpsN.dt_GPS - 4) LON(stateN.gpsN.dt_GPS - 4)];
        [d1f, ~, ~]    = ll_dist_m(pos_old_filt, pos_curr);
        d1f = d1f/4;
    end
    
    pos_old     = deg2rad(pos_old);
    pos_curr    = deg2rad(pos_curr);
    
    % Compute Speed
    Speed_m_s = abs(1000 * ( acos(sin(pos_old(1))*sin(pos_curr(1)) + ...
        cos(pos_old(1))*cos(pos_curr(1))*cos(pos_curr(2) - pos_old(2)))*6372.795477598))/ ...
        (time_GPS(stateN.gpsN.dt_GPS) - time_GPS(stateN.gpsN.dt_GPS - 1));
    
    % Heading Computation
    Z1  = sin(pos_curr(2) - pos_old(2)) * cos(pos_curr(1));
    Z2  = cos(pos_old(1)) * sin(pos_curr(1)) - sin(pos_old(1)) * cos(pos_curr(1)) * cos(pos_curr(2) - pos_old(2));
    
    HeadTmp     = (rad2deg( atan2(Z1, Z2)));
    if HeadTmp > 180
        HeadTmp = HeadTmp - 360;
    elseif HeadTmp < -180
        HeadTmp = HeadTmp + 360;
    end
    
    
    stateN.gpsN.speed_meas    = speed(stateN.gpsN.dt_GPS);
    stateN.gpsN.posConf_curr  = posConf(stateN.gpsN.dt_GPS);
    
    d2 = sum(speed(1:stateN.gpsN.dt_GPS)) - sum(speed(1:stateN.gpsN.dt_GPS -1 ));
    
    gain_dist = 1;
    if stateN.gpsN.posConf_curr > 5
        gain_dist = 0.95;
    elseif stateN.gpsN.posConf_curr > 10
        gain_dist = 0.9;
    else
        gain_dist = 1.05;
    end
    
    stateN.covered_distance    = stateN.covered_distance + mean([d1*gain_dist, d1f*gain_dist, d2*1, d2*1]);
    stateN.partial_distance    = stateN.partial_distance + mean([d1*gain_dist, d1f*gain_dist, d2*1, d2*1]);
    
    stateN.gpsN.speed_est_1          = d1/(time_GPS(stateN.gpsN.dt_GPS) - time_GPS(stateN.gpsN.dt_GPS - 1));
    stateN.gpsN.speed_est_2          = Speed_m_s;
    
    stateN.gpsN.heading_curr       = heading(stateN.gpsN.dt_GPS);
    if stateN.gpsN.heading_curr > 180
        stateN.gpsN.heading_curr = stateN.gpsN.heading_curr - 360;
    elseif stateN.gpsN.heading_curr < -180
        stateN.gpsN.heading_curr = stateN.gpsN.heading_curr + 360;
    end
    
    stateN.gpsN.heading_est        = HeadTmp;
    
    try
        if time_GPS(stateN.gpsN.dt_GPS + 1) > 0
            stateN.gpsN.dt_GPS      = stateN.gpsN.dt_GPS + 1;
        end
    catch
        % No more GPS data
    end
end