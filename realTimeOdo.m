 function [S, ddd]= realTimeOdo(previous, new_GPS)
    S = emptyOdoState();
    %if (~new_GPS.Nsats)
    %    return;
    %end
    
    earth_radius = 6371e+3;

    % P - location coefficient
    P = calculate_P(new_GPS.Error, new_GPS.Nsats);
    
    if ~previous.Valid
         if P > 0.7
            S.Good_Data = previous.Good_Data + 1;
            S.OK_Data = previous.OK_Data;
            S.Bad_Data = previous.Bad_Data;
            S.Consecutive_Bad_Counter = 0;
            S.Valid = 1;
        elseif P > 0.3
            S.Good_Data = previous.Good_Data;
            S.OK_Data = previous.OK_Data + 1;
            S.Bad_Data = previous.Bad_Data;
            S.Valid = 2;
        elseif P <= 0.3 && (previous.Consecutive_Bad_Counter > 2)
            S.Good_Data = previous.Good_Data;
            S.OK_Data = previous.OK_Data;
            S.Bad_Data = previous.Bad_Data + 1;
            S.Valid = 3;
        else
            S.Good_Data = previous.Good_Data;
            S.OK_Data = previous.OK_Data + 1;
            S.Bad_Data = previous.Bad_Data;
            S.Consecutive_Bad_Counter = previous.Consecutive_Bad_Counter + 1;
            S.Valid = 2;
        end
        
        error_radius = (180/pi) * S.Valid/earth_radius;
        S.Speed = 0;
        S.Heading = 0;
        S.LON = new_GPS.LON;
        S.LAT = new_GPS.LAT;
        S.GPS_LON = new_GPS.LON;
        S.GPS_LAT = new_GPS.LAT;
        S.Time = 0;
        S.Odo = 0;
        S.Error = error_radius;
        S.Error_meters = new_GPS.Error;
        ddd = 0;

        
    else
        if previous.GPS_LON == 0 || previous.GPS_LAT == 0 || new_GPS.LON == 0 || new_GPS.LAT == 0
            GPS_distance = 0;
            ddd = 0;
            heading_gps = 0;
            
        else
            GPS_distance = calculate_distance(previous.GPS_LON, previous.GPS_LAT, new_GPS.LON, new_GPS.LAT);
            ddd = GPS_distance;
            heading_gps = calculate_head(previous.GPS_LON, previous.GPS_LAT, new_GPS.LON, new_GPS.LAT);
        end
        time_elapsed = (new_GPS.Time - previous.Time);

        GPS_speed = GPS_distance / time_elapsed;
        if GPS_speed < 0.5 || GPS_speed > 40 || ~time_elapsed
            GPS_speed = 0;
        end
        
        if P > 0.7
            S.Good_Data = previous.Good_Data + 1;
            S.OK_Data = previous.OK_Data;
            S.Bad_Data = previous.Bad_Data;
            S.Consecutive_Bad_Counter = 0;
            S.Valid = 1;
        elseif P > 0.3
            S.Good_Data = previous.Good_Data;
            S.OK_Data = previous.OK_Data + 1;
            S.Bad_Data = previous.Bad_Data;
            S.Consecutive_Bad_Counter = previous.Consecutive_Bad_Counter;
            S.Valid = 2;
        elseif P <= 0.3 && (previous.Consecutive_Bad_Counter > 2)
            S.Good_Data = previous.Good_Data;
            S.OK_Data = previous.OK_Data;
            S.Bad_Data = previous.Bad_Data + 1;
            S.Consecutive_Bad_Counter = previous.Consecutive_Bad_Counter;
            S.Valid = 3;
        else
            S.Good_Data = previous.Good_Data;
            S.OK_Data = previous.OK_Data + 1;
            S.Bad_Data = previous.Bad_Data;
            S.Consecutive_Bad_Counter = previous.Consecutive_Bad_Counter + 1;
            S.Valid = 2;
        end
            error_radius = (180/pi) * S.Valid/earth_radius;

        if ~time_elapsed || (time_elapsed > 5) || (previous.Time == 0)
            S.Speed = GPS_speed;
            S.Heading = heading_gps;
            S.LON = new_GPS.LON;
            S.LAT = new_GPS.LAT;
            S.GPS_LON = new_GPS.LON;
            S.GPS_LAT = new_GPS.LAT;
            S.Time = new_GPS.Time;
            S.Odo = previous.Odo + GPS_distance;
            S.Error = error_radius;
            S.Error_meters = new_GPS.Error;
        else
            % K = speed coefficient
            K = 0.3;
            if abs(GPS_speed - previous.Speed) > 20
                speed = 0;
            else
                speed = previous.Speed + K * (GPS_speed - previous.Speed);
            end
            
            current_heading = calculate_heading(previous.Heading, heading_gps, P);

            change_in_x = (speed * time_elapsed) * cos(deg2rad(current_heading));
            change_in_y = (speed * time_elapsed) * sin(deg2rad(current_heading));
            
            predicted_y = previous.LAT + ((180/pi) * (change_in_y/earth_radius));
            predicted_x = previous.LON + ((180/pi) * (change_in_x/earth_radius)) / cos(previous.LAT * (pi/180));
            
            
            current_x = predicted_x + P * (new_GPS.LON - predicted_x);
            current_y = predicted_y + P * (new_GPS.LAT - predicted_y);
            
            dist = calculate_distance(previous.LON, previous.LAT, current_x, current_y);
            
            S.Speed = speed;
            S.Heading = current_heading;
            S.LON = current_x;
            S.LAT = current_y;
            S.GPS_LON = new_GPS.LON;
            S.GPS_LAT = new_GPS.LAT;
            S.Time = new_GPS.Time;
            S.Odo = previous.Odo + dist;
            S.Error = error_radius;
            S.Error_meters = new_GPS.Error;
        end
    end
    
end
function distance = calculate_distance(lon1, lat1, lon2, lat2)
    earth_radius = 6371e+3; % in meters

    lat1_rad = deg2rad(lat1);
    lat2_rad = deg2rad(lat2);
    lon1_rad = deg2rad(lon1);
    lon2_rad = deg2rad(lon2);
    lon_diff = lon2_rad - lon1_rad;
    lat_diff = lat2_rad - lat1_rad;
    a = sin(lat_diff/2)*sin(lat_diff/2) + cos(lat1_rad) * cos(lat2_rad) * sin(lon_diff/2) * sin(lon_diff/2);
    distance = (2 * atan2(sqrt(a),sqrt(1-a))) * earth_radius;
        
    if isnan(distance)
        distance = 0;
    end
end

function heading = calculate_head(lon1, lat1, lon2, lat2)
    lat1_rad = deg2rad(lat1);
    lat2_rad = deg2rad(lat2);
    lon1_rad = deg2rad(lon1);
    lon2_rad = deg2rad(lon2);
    
    lon_diff = lon2_rad - lon1_rad;
    
    x = sin(lon_diff) * cos(lat2_rad);
    y = cos(lat1_rad) * sin(lat2_rad) - sin(lat1_rad) * cos(lat2_rad) * cos(lon_diff);
    
    heading = atan2(y,x);
    heading = rad2deg(heading);
    heading = mod((heading + 360), 360);    
end

% If velocity is large, we adjust the position based on the GPS quickly
% Small velocity, we adjust the position primarily based on the prediction
function coefficient = calculate_P(error, nsats)
    if error <= 10 && nsats >= 7
        coefficient = -0.02 * error + 1;
    elseif error <= 25 && nsats > 3
        coefficient = (-0.4/15) * error + 0.7;
    elseif error <= 50 && nsats > 3
        coefficient = (-0.2/25) * error + 0.5;
    elseif ~nsats
        coefficient = 0;
    else
        coefficient = 0.1;
    end
end

function heading = calculate_heading(alpha, beta, H)
    if alpha < 90
        if beta <= 90
                heading = alpha - H*(alpha - beta);
        elseif beta <= 180
            heading = alpha + H*(beta - alpha);
        elseif beta <= 270
            if beta - 180 <= alpha
                heading = alpha + H * (beta - alpha);
            else
                heading = alpha - H * (alpha + (360-beta));
            end
        elseif beta <= 360
            heading = alpha - H * (alpha + (360-beta));
            
        end
    elseif alpha <= 180
        if beta <= 90
            heading = alpha - H*(alpha - beta);
        elseif beta <= 180
            if beta > alpha
                heading = alpha + H*(beta - alpha);
            else
               heading = alpha - H * (alpha - beta); 
            end
        elseif beta <= 270
            heading = alpha + H * (beta - alpha);
        elseif beta <= 360
            if beta < (alpha + 180)
                heading = alpha + H * (beta - alpha);
            else
                heading = alpha - H * (beta - alpha);
            end
        end
    elseif alpha <= 270
        if beta <= 90
            if beta > (alpha - 180)
                heading = alpha - H * (alpha - beta);
            else
                heading = mod(alpha + H * (180 - beta), 360);
            end
        elseif beta <= 180
            heading = alpha - H * (alpha - beta);
        elseif beta <= 270
            if beta > alpha
                heading = alpha + H * (beta - alpha);
            else
                heading = alpha - H * (alpha - beta);
            end
        elseif beta <= 360
            heading = alpha + H * (beta - alpha);
            
        end
    elseif alpha <= 360
        if beta <= 90
            heading = mod(alpha + H * (beta + (360  - alpha)), 360);
        elseif beta <= 180
            if beta <= alpha - 180
                heading = mod(alpha + H * (beta + (360  - alpha)), 360);
            else
                heading = alpha - H * (alpha - beta);
            end
        elseif beta <= 270
            heading = alpha - H * (alpha - beta);
        elseif beta <= 360
            heading = alpha + H * (beta - alpha);            
        end
    end
    
    if heading < 0
        heading = heading + 360;
    end
end