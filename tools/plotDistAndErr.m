function plotDistAndErr(data, interval)
    for i = 1:(length(data) - interval)
        one = getState(data{i});
        two = getState(data{i+interval});
        d = getDistance(one, two);
        
        res(i, 1) = d.Distance;
        res(i, 2) = d.Distance_error;
    end
    
    plot(res);
    legend('show');
    legend('Distance', 'Distance Error');
    xlabel('Time');
    ylabel('Distance / Distance Error');
end