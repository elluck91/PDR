function [ p ] = checkForLimits( p , activity)    

if activity == 1

    if length(p) > 2
        for ii = 1:length(p)
            if p(ii) < min(strideLengthConsts.walkModel_coeff_thresholds(ii,:))
                p(ii) = min(strideLengthConsts.walkModel_coeff_thresholds(ii,:));
            elseif p(ii) > max(strideLengthConsts.walkModel_coeff_thresholds(ii,:))
                p(ii) = max(strideLengthConsts.walkModel_coeff_thresholds(ii,:));
            end
        end
    else
        for ii = 1:length(p)
            if p(ii) < min(strideLengthConsts.walkModel_coeff_thresholds(ii + 1,:))
                p(ii) = min(strideLengthConsts.walkModel_coeff_thresholds(ii + 1,:));
            elseif p(ii) > max(strideLengthConsts.walkModel_coeff_thresholds(ii + 1,:))
                p(ii) = max(strideLengthConsts.walkModel_coeff_thresholds(ii + 1,:));
            end
        end
    end

elseif activity == 2
    
    if length(p) > 2
        for ii = 1:length(p)
            if p(ii) < min(strideLengthConsts.runModel_coeff_thresholds(ii,:))
                p(ii) = min(strideLengthConsts.runModel_coeff_thresholds(ii,:));
            elseif p(ii) > max(strideLengthConsts.runModel_coeff_thresholds(ii,:))
                p(ii) = max(strideLengthConsts.runModel_coeff_thresholds(ii,:));
            end
        end
    else
        for ii = 1:length(p)
            if p(ii) < min(strideLengthConsts.runModel_coeff_thresholds(ii + 1,:))
                p(ii) = min(strideLengthConsts.runModel_coeff_thresholds(ii + 1,:));
            elseif p(ii) > max(strideLengthConsts.runModel_coeff_thresholds(ii + 1,:))
                p(ii) = max(strideLengthConsts.runModel_coeff_thresholds(ii + 1,:));
            end
        end
    end
    
end