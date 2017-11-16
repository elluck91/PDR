function [ model_walk, model_run, manual_data, time_data] = testManual() 


w0  = round(strideLengthConsts.walkModel_coeff_thresholds(1,1) + ...
    (strideLengthConsts.walkModel_coeff_thresholds(1,2) - strideLengthConsts.walkModel_coeff_thresholds(1,1) )*rand(1));
w1  = round(strideLengthConsts.walkModel_coeff_thresholds(2,1) + ...
    (strideLengthConsts.walkModel_coeff_thresholds(2,2) - strideLengthConsts.walkModel_coeff_thresholds(2,1) )*rand(1));
w2  = round(strideLengthConsts.walkModel_coeff_thresholds(3,1) + ...
    (strideLengthConsts.walkModel_coeff_thresholds(3,2) - strideLengthConsts.walkModel_coeff_thresholds(3,1) )*rand(1));

model_walk  = [w0 w1 w2];

r0  = round(strideLengthConsts.runModel_coeff_thresholds(1,1) + ...
    (strideLengthConsts.runModel_coeff_thresholds(1,2) - strideLengthConsts.runModel_coeff_thresholds(1,1) )*rand(1));
r1  = round(strideLengthConsts.runModel_coeff_thresholds(2,1) + ...
    (strideLengthConsts.runModel_coeff_thresholds(2,2) - strideLengthConsts.runModel_coeff_thresholds(2,1) )*rand(1));
r2  = round(strideLengthConsts.runModel_coeff_thresholds(3,1) + ...
    (strideLengthConsts.runModel_coeff_thresholds(3,2) - strideLengthConsts.runModel_coeff_thresholds(3,1) )*rand(1));

model_run  = [r0 r1 r2];

freq        = [1.2:0.05:3];% + (-0.1 + 2*0.1*rand(1,37)); %[1.2 1.5 1.65 1.98];
stepss      = freq*100;

sl      = zeros(length(freq), 1);
activ   = zeros(length(freq), 1);

for ii = 1:length(freq)
    if freq(ii) > strideLengthConsts.freqRun_Hz
        sl(ii)    = model_run(1) + model_run(2)*freq(ii) + model_run(3)*(freq(ii).^2);
        activ(ii) = 2;
    else
        sl(ii)    = model_walk(1) + model_walk(2)*freq(ii) + model_walk(3)*(freq(ii).^2);
        activ(ii) = 1;
    end
end


dist            = sl.*stepss'/100;

manual_data     = [round([stepss' 100*ones(length(freq),1) dist] ), activ]; %+ 2*rand(length(freq),1)
manual_data     = manual_data(randperm(size(manual_data,1)),:);

time_data_tmp   = round(linspace(1000,20000, 2*length(freq)));
time_data       = reshape(time_data_tmp, 2, length(freq));
time_data       = time_data';
