function iterateThePath(data, gps_lon, gps_lat)
    % creates error circles to scale
    th = 0:pi/50:2*pi;
    count = 1;
    for i = 1:length(data)
        if data{i}.LON == 0 || data{i}.LAT == 0
            continue;
        else
            LONp(count) = data{i}.LON;
            LATp(count) = data{i}.LAT;
            for n = 1:length(th)
                xunit(count, n) = data{i}.Error * cos(th(n)) + data{i}.LON;
                yunit(count, n) = data{i}.Error * sin(th(n)) + data{i}.LAT;
            end
            count = count + 1;
        end
        
    end
    
    % Put a breakpoint at line 18 to iterate through the data points
    % one-by-one
    
    counter = 1;
    for w = 1:length(gps_lon)
        if gps_lon(w) == 0 || gps_lat(w) == 0
            continue;
        else
            x(counter) = gps_lon(w);
            y(counter) = gps_lat(w);
            counter = counter + 1;
        end
    end
    
    plot(LONp, LATp, '-', x, y, '--');
    legend('show');
    legend('Filtered Data', 'Raw Data');
    hold on;
    for m = 1:size(xunit)
        plot(xunit(m,:), yunit(m, :));
        hold on;
    end

    set(gcf,'units','normalized','outerposition',[0 0 1 1]);
    hold off;
    
    d = data{end};
    corDist = d.Odo;
    good = d.Good_Data;
    ok = d.OK_Data;
    bad = d.Bad_Data;
    fprintf(['Distance: ' num2str(corDist) '\nGood: ' num2str(good) '\nOK: ' num2str(ok) '\nBad: ' num2str(bad) '\n\n']);
end