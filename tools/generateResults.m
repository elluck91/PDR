function generateResults(name, time_interval, data)
fid = fopen(name, 'w');
fprintf(fid, 'Time, Distance From Previous Point, Distance Error From Previous Point, Cumulative Good Count, Cumulative OK Count, Cumulative Bad Count, Cumulative Error, Odometer,\n');
state_two = getState(data{1});
state(1,1) = state_two.Distance;
error = state_two.Good_Data * 0.1 + state_two.OK_Data + state_two.Bad_Data * 5;
state(1,2) = error;
state(1,3) = 1;
fprintf(fid, [num2str(1) ', ' num2str(state_two.Distance) ', ' num2str(error) ', ' num2str(state_two.Good_Data) ',' num2str(state_two.OK_Data) ',' num2str(state_two.Bad_Data) ',' num2str(error) ', ' num2str(state_two.Distance) ',\n']);

state_one = getState(data{1});
state_two = getState(data{time_interval});
d = getDistance(state_one, state_two);
ce = state_two.Good_Data * 0.1 + state_two.OK_Data +state_two.Bad_Data * 5;
fprintf(fid, [num2str(time_interval) ', ' num2str(d.Distance) ', ' num2str(d.Distance_error) ', ' num2str(state_two.Good_Data) ',' num2str(state_two.OK_Data) ',' num2str(state_two.Bad_Data) ',' num2str(ce) ', ' num2str(state_two.Distance) ',\n']);

counter = 2;
for i = 2*time_interval:time_interval:length(data);
    state_one = getState(data{i-time_interval});
    state_two = getState(data{i});
    d = getDistance(state_one, state_two);
    state(counter, 1) = state_two.Distance;
    state(counter, 2) = d.Cumulative_error;
    state(counter, 3) = i;
    counter = counter + 1;
    ce = state_two.Good_Data * 0.1 + state_two.OK_Data +state_two.Bad_Data * 5;
    fprintf(fid, [num2str(i) ', ' num2str(d.Distance) ', ' num2str(d.Distance_error) ', ' num2str(state_two.Good_Data) ',' num2str(state_two.OK_Data) ',' num2str(state_two.Bad_Data) ',' num2str(ce) ', ' num2str(state_two.Distance) ',\n']);
end

state_one = getState(data{i});
state_two = getState(data{end});
d = getDistance(state_one, state_two);
state(end + 1, 1) = state_two.Distance;
state(end, 2) = d.Cumulative_error;
state(end, 3) = length(data);
ce = state_two.Good_Data * 0.1 + state_two.OK_Data +state_two.Bad_Data * 5;
fprintf(fid, [num2str(state_two.Timestamp) ', ' num2str(d.Distance) ', ' num2str(d.Distance_error) ', ' num2str(state_two.Good_Data) ',' num2str(state_two.OK_Data) ',' num2str(state_two.Bad_Data) ',' num2str(ce) ', ' num2str(state_two.Distance) ',\n']);
fclose(fid);

legend('show');
plot(state(:, 3), state(:,1));
t = xlabel('Time');

hold on;
plot(state(:, 3), state(:,2));
y2 = ylabel('Distance / Distance Error');
legend('Distance','Distance Error')
hold off;
end