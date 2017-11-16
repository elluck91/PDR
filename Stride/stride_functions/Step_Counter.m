function [ state, norm_FIFO, peaks_dec ] = Step_Counter(state, samp_curr, acc_f, time_sens, norm_FIFO, peaks_dec)  
% This Function computes the number of steps the user is doing when
% walking, based on accelerometer data

% state.stepN.dt_step = dt_step(samp_curr);
% state.stepN.dt_step_prec = dt_step(samp_curr - 1);

% Consider three adjacent measures of the 3D accelerometer
    acc_curr        = [acc_f(samp_curr-2, :); acc_f(samp_curr-1, :); acc_f(samp_curr, :)];
    % Compute the associated acc norm measure (square), which will be used as basis
    % for the pedometer step counter processing.
    norm_square     = [sqrt(sum(acc_curr(1,:).^2)); ...
                       sqrt(sum(acc_curr(2,:).^2)); ...
                       sqrt(sum(acc_curr(3,:).^2))].^2;
    % 'norm_3D' is computed and then used as a first flag for discerning a
    % peak in the acc norm function
    norm_3D         = mean(norm_square);
    % 'norm_FIFO' takes into account the variability of the peak values
    % with a moving windowing concept
    norm_FIFO(samp_curr)        = norm_3D;
    state.stepN.t_step_curr     = time_sens(samp_curr);     % current time

    % Define the threshold on the energy function in order to flag a possible peak (step)    
    if samp_curr <= 250
        threshold_norm_neg  = 0.52*mean(norm_FIFO(round(1 + samp_curr/10):samp_curr));
        threshold_norm_pos  = 1.2*mean(norm_FIFO(round(1 + samp_curr/10):samp_curr));
    else
        threshold_norm_neg  = 0.52*mean(norm_FIFO(samp_curr - 250:samp_curr));
        threshold_norm_pos  = 1.2*mean(norm_FIFO(samp_curr - 250:samp_curr));
    end
    %%%%% Step counter - based on peaks of energy function from ACC
    % Step detection is based on the following:
    %   - the three considered energy points are beyond the threshold
    %   - the median energy value is higher than the lateral ones (flag for a maximum)
    %   - the estimated elapsed time_sens based on the previous hystory
    
    flag_negative_peak = ((norm_3D  < threshold_norm_neg) && ((norm_square(1) - norm_square(2)) > 0) ...
            && ((norm_square(2) - norm_square(3)) < 0));
    flag_positive_peak = ((norm_3D  > threshold_norm_pos) && ((norm_square(1) - norm_square(2)) < 0) ...
            && ((norm_square(2) - norm_square(3)) > 0));
%     
    if ( flag_negative_peak || flag_positive_peak ) && abs(norm_square(2) - state.stepN.value) > 0.5 && ...
            (state.stepN.t_step_curr - state.stepN.t_step_old) > min(0.25, 0.65*mean(state.stepN.step2step_time)) 
%         
            
%     if ( flag_positive_peak ) && ... %abs(norm_square(2) - state.stepN.value) > 0.5 && ...
%             (state.stepN.t_step_curr - state.stepN.t_step_old) > min(0.28, 0.7*mean(state.stepN.step2step_time)) 
     
        % Define a simple mode to evaluate if a missed step has been
        % encountered - ex. if one step is missing
        state.stepN.step_old = state.stepN.step_count;
             
        if (state.stepN.t_step_curr - state.stepN.t_step_old) < 1.5*mean(state.stepN.step2step_time)
            state.stepN.step_par    = state.stepN.step_par + 1;         % partial step counter (from last GPS update)
            state.stepN.step_count  = state.stepN.step_count + 1;       % cumulative step counter
        elseif (state.stepN.t_step_curr - state.stepN.t_step_old) > 1.85*mean(state.stepN.step2step_time) && ...
               (state.stepN.t_step_curr - state.stepN.t_step_old) < 2.15*mean(state.stepN.step2step_time)
            state.stepN.step_par    = state.stepN.step_par + 2;
            state.stepN.step_count  = state.stepN.step_count + 2;       % cumulative step counter
        end
        
        % save last time_sens stamp when in this cycle (time_sens stamp of the last detected step)
        state.stepN.t_step_old      = time_sens(samp_curr);

        if abs(state.stepN.step_count - state.stepN.step_old) > 0  % if actually a step is detected
            peaks_dec(samp_curr - 1)    = norm_square(2);           % peak value @ step detection
            state.stepN.value           = norm_square(2);
        
            % update the buffer - include distance between every detected
            % peak
            state.stepN.step2step_time_buffer(1:end - 1)    = state.stepN.step2step_time_buffer(2:end);
            state.stepN.step2step_time_buffer(end)          = state.stepN.dt_step_prec;
            
            state.stepN.dt_step     = 0;    % reset timer because a step is detected - ready for the next one
            if flag_negative_peak
                state.stepN.dt_peak = 0;
            end
        end
        
        % In order to compute, by step count, the var SF, include a small
        % FIFO to be more confident
        if length(state.stepN.step2step_time) > state.strideN.SF_FIFO ...
                && state.stepN.dt_step_prec < 1.15*median(state.stepN.step2step_time_buffer) && ...
                state.stepN.step_par~=0
            % Want to take in account the computation of SF after a 'not
            % moving' phase, when the last dt_step element is of course
            % erroneous (it considers a very long step)
            if state.stepN.step2step_time(end) > 2.5*median(state.stepN.step2step_time(1:end-1))
                state.stepN.partial_distance    = 0;
                state.stepN.step_par            = 0;
            end
            
            state.stepN.step2step_time      = [state.stepN.step2step_time(end - state.strideN.SF_FIFO: end) state.stepN.dt_step_prec];
%             state.stepN.p2p_time            = [state.stepN.p2p_time(end - state.strideN.SF_FIFO: end) state.stepN.dt_peak_prec];
            
            % Compute SF and SL in the model format, by applyng also a low
            % pass filtering
            
            if state.stepN.step2step_time(end) < 2.5*median(state.stepN.step2step_time(1:end-1))
                state.strideN.SF_comp     = state.stepN.coeff_filt*state.strideN.SF_comp + (1 - state.stepN.coeff_filt)*0.5/mean(state.stepN.step2step_time);
                state.stepN.coeff_filt  = 0.5;
                if state.strideN.SF_comp < 0.5
                    state.strideN.SF_comp   = 0;
                    state.stepN.coeff_filt  = 0;
                end               
            else
                state.strideN.SF_comp = 0;                
            end
            state.strideN.SL_comp     = state.userN.User_heigth/algoConsts.default_heigth*(state.strideN.walkModel.walk_x0 +...
                state.strideN.walkModel.walk_x*state.strideN.SF_comp + state.strideN.walkModel.walk_x2*state.strideN.SF_comp^2);  
        else  
            state.stepN.step2step_time = [state.stepN.step2step_time  state.stepN.dt_step_prec];
        end
    else
        % compute the elapsed time_sens from the last detected step
        state.stepN.dt_step = state.stepN.dt_step_prec + 1*(time_sens(samp_curr) - time_sens(samp_curr - 1));         
    end
    state.stepN.dt_step_prec = state.stepN.dt_step;

    