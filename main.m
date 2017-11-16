clear; close;
addpath(genpath(pwd))

%% LOG parsing
    rootDir = fullfile(pwd,'Data_test');
    repo    = list_ls(rootDir);

    index_file  = 10;
    file        = repo{index_file};
    file        = file(1:15);

    log_input   = fullfile(rootDir, file);
    %try
    %    ~isempty(sensData);
    %catch
        sensData    = plotSensorData('topdir', log_input, 'plotting', 0);     % Sensors data
    %end

    %try
    %    ~isempty(GPSData);
    %catch
        GPSData     = plotGPSData('topdir', log_input);     % GPS data
    %end

    %% MANAGE DATA IN
    bound_data = 50;

    ACC = [sensData.acc.x(bound_data:end -bound_data)' sensData.acc.y(bound_data:end -bound_data)' sensData.acc.z(bound_data:end -bound_data)'];
    GYR = [sensData.gyr.x(bound_data:end -bound_data)' sensData.gyr.y(bound_data:end -bound_data)' sensData.gyr.z(bound_data:end -bound_data)'];
    MAG = [sensData.mag.x(bound_data:end -bound_data)' sensData.mag.y(bound_data:end -bound_data)' sensData.mag.z(bound_data:end -bound_data)'];

    time_sens   = sensData.acc.t(bound_data:end -bound_data)/1000;
    time_sens   = time_sens - time_sens(1);  % [ms]
    Ts_sens     = mean(diff(time_sens));

    % time_sens = [1:length(ACC)]/stepConsts.samplingRate;

    LAT         = GPSData.locData.lat(2:end);
    LON         = GPSData.locData.lon(2:end);
    posConf     = GPSData.locData.posConf(2:end);
    Nsats       = GPSData.locData.Nsats(2:end);
    vel_raw     = GPSData.speedData.val(2:end);
    head_raw    = GPSData.headData.val(2:end);
    time_GPS    = GPSData.locData.UTC(2:end);
    time_GPS    = (time_GPS - time_GPS(1))/1000;
    time_GPS(3) = 2; % error in the logs used

    for i = 1:length(time_GPS)
        GPS_data(i) = struct('LAT', LAT(i), 'LON', LON(i), 'Error', posConf(i), 'Nsats', Nsats(i), 'Time', time_GPS(i));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Odometer
    distance_gps = 0;
    Data_counter = 1;

    Processed_Data{1} = emptyOdoState;
    emptyState = emptyOdoState;
    [data, ddd] = realTimeOdo(emptyState, GPS_data(1));
    distance_gps = distance_gps + ddd;
    Processed_Data{Data_counter} = data;
    if data.Valid
        Data_counter = Data_counter + 1;
    end
    
    GPS_counter = 2;

    while GPS_counter < length(time_GPS)
        if (Data_counter == 1)
            [data, ddd] = realTimeOdo(Processed_Data{Data_counter}, GPS_data(GPS_counter));
                distance_gps = distance_gps + ddd;

        else
            [data, ddd] = realTimeOdo(Processed_Data{Data_counter-1}, GPS_data(GPS_counter));
                distance_gps = distance_gps + ddd;

        end

        if data.Valid
            Processed_Data{Data_counter} = data;
            Data_counter = Data_counter + 1;
        end
        GPS_counter = GPS_counter + 1;        
    end
    
    iterateThePath(Processed_Data, LON, LAT);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    generateResults('Test1s.csv', 1, Processed_Data);
    %generateResults('Test10s.csv', 10, Processed_Data);
    plotDistAndErr(Processed_Data, 1);
    %plotDistAndErr(Processed_Data,10);

% Filter
N       = 2;                             % filter order
fs      = 1/Ts_sens;                     % sampling freq
f       = 4.2;                           % cut freq
[B,A]   = butter(N,f/(fs/2),'low');
% 
% len     = min(length(ACC), length(GYR));
% decim   = round(len/length(MAG));
% MAG     = resample(double(MAG), decim, 1);
% len     = min(len, length(MAG));
% 
% acc_f   = filter(B,A, ACC(1:len, :));
% gyr_f   = filter(B,A, GYR(1:len, :));
% mag_f   = filter(B,A, MAG(1:len, :));
% 
[Bs,As] = butter(N, 5/(fs/2),'low');
GPS_speed   = filter(Bs,As, vel_raw);
GPS_speed(GPS_speed < 0)    = 0;

[Bh,Ah] = butter(N, 5/(fs/2),'low');
heading = filter(Bh,Ah, head_raw);
% 
% t_tmp     = time_sens(1:len)/1000;
% time_sens = t_tmp;

%% INIT VAR

TEST_CONVERGENCE = 0; % for manual learning
% Var Init and parameters definition  
% stateN = Init_var(); 

% Define the Reference Model for the Artifical Pattern
manual_data = [];
[model_walk, model_run, manual_dataSet, time_data ] = testManual();


stateN      = emptyStepDetection();
step_old    = 0;
step_time   = [];
step_freq   = [];
step_norm   = [];
step_freqConf   = [];
steps.Nsteps = 0;

     
% Slope acceptance parameters
slope_curr  = 1;
slope_max   = 1.5;
slope_min   = 0.5;
        
state = defaultStrideLength(emptyStrideLength);

% User info - user heigth Vs default
gain_sl = 185/185;

% Init Vectors
peaks_dec       = zeros(length(time_sens),1);
dt_step         = zeros(length(time_sens),1);
norm_FIFO       = zeros(length(time_sens),1);
SLest           = zeros(length(time_sens),1);
SFest           = zeros(length(time_sens),1);
norm_vec        = zeros(length(time_sens),1);

count_steps     = zeros(length(time_sens),1);
count_dist      = zeros(length(time_sens),1);
speed_gps       = zeros(length(time_sens),1);
speed_est       = zeros(length(time_sens),1); 
speed_est2      = zeros(length(time_sens),1); 
posConf_meas    = zeros(length(time_sens),1); 
head_est        = zeros(length(time_sens),1); 
head_meas       = zeros(length(time_sens),1);

% Possible use of Sensor Fusion for Heading evaluation
% AHRS = Algo_AHRS('SamplePeriod', Ts_sens, 'Beta', 0.15); % could be used for heading checks

ind_t = 1;

h = waitbar(0,'SL Algorithm - Processing ...');
for samp_curr = 3:length(time_sens)-1
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                                          %
        %      STEP COUNTER and STEP FREQUENCY     %
        %                                          %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    steps.Nm1steps = steps.Nsteps;
    [ stateN, ifResultedUpdated ] = RunStepDetectionModule( stateN, ACC(samp_curr,1), ACC(samp_curr,2), ACC(samp_curr,3), time_sens(samp_curr) );
        
%     [ stateN, norm_FIFO, peaks_dec ] = ...
%         Step_Counter(stateN, samp_curr, acc_f, time_sens, norm_FIFO, peaks_dec);
    %%%%%%%% ^^ TO BE REPLACED WITH OFFICIAL PEDOMETER ^^ %%%%%%
    
    % Output:
    % - step number ---> state.stepN.step_count
    % - step freq   ---> state.strideN.SF_comp
    % - time        ---> time_sens(samp_curr)
    steps.time      = time_sens(samp_curr);
    steps.Nsteps    = stateN.stepResults.Nsteps;            % stepN.step_count;
    steps.freq      = stateN.stepFrequency.value;           % strideN.SF_comp;
    steps.dist_cm   = stateN.covered_distance;              % stepN.covered_distance;
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %                                          %
        %          MANUAL INPUT FROM USER          %
        %                                          %    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Include data from the user. He's flagging the learning session, so that
    % at the beginning of each session each step is processed and verified to
    % hold on the same segment
%     Tin = 0; Tout = 0;
%     if samp_curr == 1000
%         Tin = 1000; Tout = 7800;
%         manual_data = [225  143.7  139.8  1];   % [steps  time  dist activity]  % data from logs
%     elseif samp_curr == 9200
%         Tin = 9200; Tout = 12950;
%         manual_data = [181  97.7  137.4  1];   % [steps  time  dist activity]  % data from logs
% %         state.userInfo.height_cm = 180;       % Simulate a change of the userID ---> should reset the previous input data
%     elseif samp_curr == 13850
%         Tin = 13850; Tout = 17700;
%         manual_data = [167  79.7  139.2  1];   % [steps  time  dist activity]  % data from logs
%     elseif samp_curr == 19600
%         Tin = 19600; Tout = 21800; 
%         manual_data = [92   57.7  120.8  1];   % [steps  time  dist activity]  % data from logs
%     end

    if TEST_CONVERGENCE
        if ind_t < length(manual_dataSet)
            Tin     = time_data(ind_t, 1);
            Tout    = time_data(ind_t, 2);
            manual_data = manual_dataSet(ind_t,:);    % data from test model
        end

        if ~isempty(manual_data)
            [ state, manual_data ] = User_Learn_Session(state, stateN, steps, [Tin Tout], samp_curr, manual_data, TEST_CONVERGENCE);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        %                                         %
        %        GPS --- SEGMENT EXTRACTION       %
        %                                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Comment if want to test manual input part
        if ~TEST_CONVERGENCE
            if state.model ~= 2 && GPS_available(samp_curr)   % GPS on and user not logging learning sessions
                state.model     = 1;
                [ state ] = LearningModule(state, steps);
            end
        end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %                                         %
        %      GPS --- DISTANCE INFORMATION       %
        %                                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    [stateN, time_GPS ] = distanceFrom_GPS(stateN, samp_curr, time_sens, time_GPS, LAT, LON, GPS_speed, posConf, heading);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        %                                         %
        %              UPDATE MODEL               %
        %                                         %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Run the UPDATE function when new info is available
    if state.CalRef.enable  % enable when a new Calibration element (segment) is available
        state.CalRef.enable = 0;
        
        slope_in_range = 1;
        
        switch state.manual_input.flag     % the new segment comes from the User
            case 1
                state.manual_input.flag = 0;
                
                info.segment_steps      = state.manual_input.Nsteps;
                info.segment_time       = state.manual_input.Time;
                info.segment_distance   = state.manual_input.Dist_cm;
                info.activity           = state.manual_input.activity;
                
            case 0                
                info.segment_steps      = state.CalRef.LastValidStep - state.CalRef.refStep;
                info.segment_time       = state.CalRef.LastValidTime - state.CalRef.refTime;
                info.segment_distance   = state.CalRef.LastDistance	 - state.CalRef.refDist_cm;
                info.activity           = state.CalRef.Activity_curr;
        end
        
        if state.strideCalInfo.CalInfo_buffer > 0
            % Want to compare the novel segment with the last one accepted and used to the
            % update of the model
            info_step_old   = state.strideCalInfo.Nsteps(state.strideCalInfo.CalInfo_buffer);
            info_time_old   = state.strideCalInfo.dTime(state.strideCalInfo.CalInfo_buffer);
            info_dist_old   = state.strideCalInfo.Dist_cm(state.strideCalInfo.CalInfo_buffer);
            info_freq_old   = info_step_old/info_time_old;
            
            [ slope_in_range ]  = slope_range(state, info_freq_old, info);            
        end
            
            %%%%%%% NEED TO IMPROVE THIS PART - too sensible to outliers points
            % Acceptance of the novel point to update the model
%             if slope_in_range
                [ state ]  = strideCalInfo_buffer_update(state, info);
                [ state ]  = updateModel(state);
%             end
            
        coeff_walk(ind_t,:) = [state.walkModel.x0, state.walkModel.x, state.walkModel.x2];
        coeff_run(ind_t,:) = [state.runningModel.x0, state.runningModel.x, state.runningModel.x2];
        ind_t = ind_t + 1;
        
        
        %%%%%%%
        
        % After update, reset 
        state   = resetCalstate(state);
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
    % If the user is moving, compute the stride length by means of the dedicated function
    if stateN.ifWalking   % walking
        stride = getStrideLength(state, steps);
        state.strideLength = stride.L_cm;
    end
    
    SLest(samp_curr)        = state.strideLength;
    SFest(samp_curr)        = stateN.stepFrequency.value;   
    
    norm_vec(samp_curr)     = stateN.stepResults.Norm;
    
    count_steps(samp_curr)  = stateN.stepsRes.nSteps;
    count_dist(samp_curr)   = stateN.covered_distance;
    speed_gps(samp_curr)    = stateN.gpsN.speed_meas;
    speed_est(samp_curr)    = stateN.gpsN.speed_est_1;
    speed_est2(samp_curr)   = stateN.gpsN.speed_est_2;
    
    posConf_meas(samp_curr) = stateN.gpsN.posConf_curr;
    head_meas(samp_curr)    = stateN.gpsN.heading_curr;
    head_est(samp_curr)     = stateN.gpsN.heading_est;

    waitbar(samp_curr/(length(time_sens) - 4), h, sprintf('SL Algorithm - Processing ... %.1f %%',100*samp_curr/(length(time_sens) - 4)));
end
close(h);

%% FIGURES
% Figures on datalog tests

close all
Norm = (ACC(:,1).^2 + ACC(:,2).^2 + ACC(:,3).^2).^(1/2);

figure(1)
plot(time_sens, Norm); hold all
plot(time_sens, norm_vec,'*')
xlabel 'time'
ylabel 'Acceleration norm'

figure(2)
ax = plotyy(time_sens, SFest, time_sens, SLest); hold all
ylabel(ax(1), 'step freq [s^{-1}]');
ylabel(ax(2), 'step length [cm]');
xlabel( 'time [s]');
title 'step frequency VS step length estimation'

figure(3)
subplot 211; plot(ones(length(coeff_walk),1)*model_walk,'-.'); hold all; plot(coeff_walk, 'Linewidth', 2); 
title 'Model coefficients - updating steps'
ylabel 'Walking'
legend 'const Ref' 'lin Ref' 'quad Ref' 'const' 'lin' 'quad'
subplot 212; plot(ones(length(coeff_run),1)*model_run, '-.'); hold all; plot(coeff_run, 'Linewidth', 2); 
ylabel 'Running'
xlabel 'updating step'
legend 'const Ref' 'lin Ref' 'quad Ref' 'const' 'lin' 'quad'

% heading plot (not used in the code)
figure(4)
plot(time_sens, head_meas); hold all
plot(time_sens, head_est);
