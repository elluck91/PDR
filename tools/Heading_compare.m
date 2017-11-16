clear; close all; clc

%% LOG parsing

rootDir = '/home/murar/Documents/MATLAB/Stride_Length/Data_test';
repo            = list_ls(rootDir);

index_file = 5;
file = repo{index_file};
file = file(1:15);

% Sensors data
log_input   = fullfile('/home/murar/Documents/MATLAB/Stride_Length/Data_test', file);
% GPS data
GPSData     = plotGPSData('topdir', log_input);

%% INIT
lat0    = GPSData.locData.lat(1);
lon0    = GPSData.locData.lon(1);
lat_est = zeros(length(GPSData.locData.UTC)-5,1);
lon_est = zeros(length(GPSData.locData.UTC)-5,1);
lat_estREAD = zeros(length(GPSData.locData.UTC)-5,1);
lon_estREAD = zeros(length(GPSData.locData.UTC)-5,1);
dist1   = zeros(length(GPSData.locData.UTC)-5,1);
dist2   = zeros(length(GPSData.locData.UTC)-5,1);

lat_est(1) = lat0;
lon_est(1) = lon0;
lat_estREAD(1)  = lat0;
lon_est2READ(1) = lon0;

total_dist  = 0;
time_GPS    =  (GPSData.locData.UTC-GPSData.locData.UTC(1))/1000;
Speed_est   = zeros(length(time_GPS),1);
Heading_est = zeros(length(time_GPS),1);


flag_realTime = 0;

%% RUN
for ii = 2:length(time_GPS)
    
    lat_old     = GPSData.locData.lat(ii - 1);
    lon_old     = GPSData.locData.lon(ii - 1);
    lat_curr    = GPSData.locData.lat(ii);
    lon_curr    = GPSData.locData.lon(ii);
    
    lon_curr    = deg2rad(lon_curr);
    lon_old     = deg2rad(lon_old);
    lat_curr    = deg2rad(lat_curr);
    lat_old     = deg2rad(lat_old);

    Speed_m_s = abs(1000 * ( acos(sin(lat_old)*sin(lat_curr) +...
        cos(lat_old)*cos(lat_curr)*cos(lon_curr-lon_old))*6372.795477598))/(time_GPS(ii)-time_GPS(ii-1))	;	

    [d1, ~, ~]  = ll_dist_m([GPSData.locData.lat(ii - 1) GPSData.locData.lon(ii - 1)],[GPSData.locData.lat(ii) GPSData.locData.lon(ii)]);
    total_dist  = total_dist + d1;
    delta_t     = time_GPS(ii) - time_GPS(ii-1);
    dist1(ii)   = d1;
    dist2(ii)   = Speed_m_s*delta_t;
        
    % Heading Computation
    Z1 = sin(lon_curr - lon_old) * cos(lat_curr);
    Z2 = cos(lat_old) * sin(lat_curr)...
        - sin(lat_old) * cos(lat_curr) * cos(lon_curr - lon_old);
    HeadTmp = (rad2deg( atan2(Z1, Z2)));
    if HeadTmp > 180
        HeadTmp = HeadTmp - 360;
    elseif HeadTmp < -180
        HeadTmp = HeadTmp + 360;
    end
    
    %%%%%%%%%%% Compute path and distance based on speed and heading %%%%%
    angleRadHeading     = deg2rad(HeadTmp);
    kmDistance          = Speed_m_s*(time_GPS(ii) - time_GPS(ii-1));
    distRatio           = kmDistance / (6372.795477598*1000);
    distRatioSine       = sin(distRatio);
    distRatioCosine     = cos(distRatio);
    
    startLatRad         = deg2rad(lat0);
    startLonRad         = deg2rad(lon0);
    
    startLatCos         = cos(startLatRad);
    startLatSin         = sin(startLatRad);
    
    endLatRads  = asin((startLatSin * distRatioCosine) + (startLatCos * distRatioSine * cos(angleRadHeading)));
    endLonRads  = startLonRad + atan2(sin(angleRadHeading) * distRatioSine * startLatCos, distRatioCosine - startLatSin * sin(endLatRads));
    
    lat0        = rad2deg(endLatRads);
    lon0        = rad2deg(endLonRads);
    
    lat_est(ii) = lat0;
    lon_est(ii) = lon0;
    
    %%%%%%%%% Compute path and distance based on speed and heading (from GPS) %%%%%
    angleRadHeading     = deg2rad(GPSData.headData.val(ii));
    kmDistance          = GPSData.speedData.val(ii)*(time_GPS(ii) - time_GPS(ii-1));
    distRatio           = kmDistance / (6372.795477598*1000);
    distRatioSine       = sin(distRatio);
    distRatioCosine     = cos(distRatio);
    
    startLatRad         = deg2rad(lat0);
    startLonRad         = deg2rad(lon0);
    
    startLatCos         = cos(startLatRad);
    startLatSin         = sin(startLatRad);
    
    endLatRads      = asin((startLatSin * distRatioCosine) + (startLatCos * distRatioSine * cos(angleRadHeading)));
    endLonRads      = startLonRad + atan2(sin(angleRadHeading) * distRatioSine * startLatCos, distRatioCosine - startLatSin * sin(endLatRads));
    
    lat02    = rad2deg(endLatRads);
    lon02    = rad2deg(endLonRads);
    
    lat_estREAD(ii) = lat02;
    lon_estREAD(ii) = lon02;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Speed_est(ii)   = Speed_m_s;
    Heading_est(ii) = HeadTmp;
end

%% FIGURES

figure(1)
    subplot 221; plot(lat_est, lon_est,'*'); hold all
    ylabel 'latitude [deg]'
    xlabel 'longitude [deg]'
    plot(lat_estREAD, lon_estREAD,'k-o');
    plot(GPSData.locData.lat, GPSData.locData.lon,'-o')
    title 'Speed/Heading VS LAT/LON' 
    legend 'Speed/Head est from Lat/Lon' 'Speed/Head from data' 'Lat/Lon from data'

    subplot 222; plot(Speed_est); hold all
    xlabel 'time [s]'
    ylabel 'speed [m/s]'
    plot(GPSData.speedData.val); 
    title 'Speed [m/s]'
    legend 'Speed estimated from Lat/Lon' 'Speed from data'

    subplot 223; plot(dist1,'*'); hold all
    xlabel 'time [s]'
    ylabel 'distance [m]'
    plot(dist2,'-o');
    title 'distance'
    legend 'Speed estimated from Lat/Lon' 'Speed from data'

    subplot 224; plot(Heading_est); hold all
    xlabel 'time [s]'
    ylabel 'heading [deg]'
    plot(wrapTo180(GPSData.headData.val));
    title 'Heading from GPS'
    legend 'Heading estimated from Lat/Lon' 'Heading from data'

%% PLOT Pos - Direction

if flag_realTime
    LAT = lat_est;
    LON = lon_est;
    
    figure('Name','Compare Pos/head')
    for k = 1:length(LAT);
        subplot 211; plot(LAT(1:k), LON(1:k), '-o');
        xlabel('longitude'); ylabel('latitude')
        axis(abs([min(LAT) max(LAT) min(LON) max(LON)]))
        subplot 212; plot(time_GPS(1:k),Heading_est(1:k), '-o');
        xlabel('time'); ylabel('heading [deg]')
        axis([0 time_GPS(end) min(Heading_est) max(Heading_est)])
        
        M(k) = getframe;
    end
    
end
