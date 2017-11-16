function [ state ] = strideCalInfo_buffer_update(state, info)

state.strideCalInfo.flag_buffer_upd     = 0;
[ dev ]  = checkForDev(state, info);

if dev < 0.35
    
    curr_sizeCal_buffer = state.strideCalInfo.CalInfo_buffer;
    
    % Define two different behaviours in populating buffer, dependening if
    % buffer is already full or not
    
    % Fill buffer
    if curr_sizeCal_buffer < strideLengthConsts.max_sizeCal_buffer
        % Fill buffer
        state.strideCalInfo.Nsteps(curr_sizeCal_buffer + 1)    = info.segment_steps;  % could be included by the user or verified by pedometer
        state.strideCalInfo.dTime(curr_sizeCal_buffer + 1)     = info.segment_time;    % taken from the training log
        state.strideCalInfo.Dist_cm(curr_sizeCal_buffer + 1)   = info.segment_distance; % the User has to include it in the training log
        
        state.strideCalInfo.f_sum(curr_sizeCal_buffer + 1)     = state.CalRef.stepfreqSum;
        state.strideCalInfo.f2_sum(curr_sizeCal_buffer + 1)    = state.CalRef.stepfreq_2_Sum;
        state.strideCalInfo.freq_std(curr_sizeCal_buffer + 1)  = state.CalRef.stepStd;
        
        try
            state.strideCalInfo.step_type(curr_sizeCal_buffer + 1) = info.activity;
        catch
            state.strideCalInfo.step_type(curr_sizeCal_buffer + 1) = state.CalRef.Activity_curr;
        end
        
        % update buffer size info
        state.strideCalInfo.CalInfo_buffer  = state.strideCalInfo.CalInfo_buffer + 1;
        state.strideCalInfo.flag_buffer_upd = 1;
        
    else
        % Define how to fill the buffer and replace one element inside. Want to
        % replace one element with another one which could add more information
        
        % First Check - Activity. Want to balance the number of data for each
        % activity, considering also the activity is more frequent in recend
        % recorded logs. Define a minimum of 3 points for each activity
        
        % Same activity
        try
            same_activity = find(state.strideCalInfo.step_type == info.activity);
        catch
            same_activity = find(state.strideCalInfo.step_type == state.CalRef.Activity_curr);
        end
        
        % Different_activity
        try
            diff_activity = find(state.strideCalInfo.step_type ~= info.activity);
        catch
            diff_activity = find(state.strideCalInfo.step_type ~= state.CalRef.Activity_curr);
        end
        
        if length(same_activity) < 6  % Replace points with different activity
            [~, ind] = max(state.strideCalInfo.freq_std(diff_activity));
            ind_replace = diff_activity(ind);
            
            [ state ] = replacePoint_buffer( state, info, ind_replace);
            state.strideCalInfo.flag_buffer_upd  = 1;
                        
        else % Replace points with same activity
            
            [min_f_buffer, ind_min] = min(state.strideCalInfo.Nsteps(same_activity)./state.strideCalInfo.dTime(same_activity));
            ind_min = same_activity(ind_min);
            [max_f_buffer, ind_max] = max(state.strideCalInfo.Nsteps(same_activity)./state.strideCalInfo.dTime(same_activity));
            ind_max = same_activity(ind_max);
            
            % Check for frequency span (greater span, better results)
            if (info.segment_steps/info.segment_time) < min_f_buffer
                ind_replace = ind_min;
            elseif (info.segment_steps/info.segment_time) > max_f_buffer
                ind_replace = ind_max;
            end
            
            % If no possibility to extend freq span, then replace the point
            % with higher frequency std
            if (info.segment_steps/info.segment_time) >= min_f_buffer && ...
                    (info.segment_steps/info.segment_time) <= max_f_buffer
                
                [~, ind] = max(state.strideCalInfo.freq_std(same_activity));
                ind_replace = same_activity(ind);
            end
                     
            [ state ] = replacePoint_buffer( state, info, ind_replace);
            state.strideCalInfo.flag_buffer_upd  = 1;
     
        end
              
        % circle buffer - old logics
        %     [ state ] = circleBuffer(state, info);
        
    end

end

end