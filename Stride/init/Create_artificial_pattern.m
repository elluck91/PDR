function [ path ] = Create_artificial_pattern(n_seg, freq_min, freq_max, model)
% This function is responsible to create a randomised pattern in the form
% walking-still format. The User is supposed to register a learning log
% where he's walking at different speeds. 

t_set       = 0;
der_step    = zeros(n_seg, 1);
segment_move    = 150;
segment_still   = 50;


for ni = 1:n_seg
    t_set = [t_set max(t_set) + segment_move + segment_still*abs(rand(1))];   
    if mod(ni,2) == 0
        der_step(ni) = freq_min + (freq_max - freq_min)*rand(1);        
    else
        der_step(ni) = 0;
    end     
end
der_step(end+1) = 0;

index_old = 1;

time    = 0:0.1:max(t_set);
step_n  = zeros(length(time), 1);
freq    = zeros(length(time), 1);
dist    = zeros(length(time), 1);
walking_en = zeros(length(time), 1);
offset  = 0;
alpha   = 0;
walk_flag   = 0;
off_time    = 0;
freq(1)     = 0;
off_step    = 0;

for ii = 2:length(time)
    index_new = find(t_set < time(ii),1,'last');
    if index_new ~= index_old
        alpha       = der_step(index_new);
        offset      = max(step_n) - alpha*time(ii);
        walk_flag   = der_step(index_new) > 0;
        off_time    = time(ii-1);
        off_step    = step_n(ii-1);
    end
    
    % Step number is integer, suppose the freq rate constant
    step_n(ii)  = ceil(offset + alpha*time(ii) + 0*rand(1));
    % Add a filter on the frequency 
    freq(ii)    = 0.9*freq(ii-1) + 0.1*(step_n(ii) - off_step)/(time(ii) - off_time);
    
    % Compute the step length on the reference model basis
    x_CONST     = model(1);
    x_LIN       = model(2);  
    x_QUAD      = model(3);
    stepLen = walk_flag*(x_CONST + x_LIN*(mean(freq(ii))) + x_QUAD*(mean(freq(ii)))^2);

    dist(ii) = dist(ii-1) + stepLen*(step_n(ii) - step_n(ii-1));
    if dist(ii) < 0
        dist(ii) = 0;
    end
    index_old   = index_new;
    walking_en(ii) = walk_flag;
end
dist = dist/100; % cm to m

path.time   = time;
path.dist   = dist;
path.step_n = step_n;
path.freq   = freq;
path.walking_en = walking_en;

path.t_set      = t_set;
path.der_step  = der_step;

%%
figure(1)
subplot 211; ax = plotyy(time,step_n, time, freq); hold all; grid
ylabel(ax(1), 'step counter');
ylabel(ax(2), 'step frequency');
xlabel 'time [s]'
subplot 212; plot(time, dist,'k'); grid
ylabel 'distance [m]'

