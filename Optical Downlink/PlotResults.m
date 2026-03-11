close all
clear

SAMPLE_TIME = 0.5;

durations = readtable("DurationsTable_1YR_results.csv");

% Convert to seconds
durations(:,2) = durations(:,2) .* SAMPLE_TIME;

scatter(durations{:, 1}, durations{:,2})
title("Durations of access intervals over a year")
xlabel("Date")
ylabel("Duration (s)")
ylim([0 (max(durations{:,2}) + 2)])

% Get average duration
meanDuration = mean(durations(:,2));

rows = size(durations, 1);

% Get time between access intervals (days)
timeBetweenAccess = zeros(rows - 1,1);

for i = 1:(rows - 1)
    difference = durations(i + 1, 1) - durations(i, 1);
    timeBetweenAccess(i, 1) = days(difference{1,1});
end

avgTimeBetween = mean(timeBetweenAccess);    % in days

figure
scatter(1:rows - 1, timeBetweenAccess(:,1))
title("Time Between Access Intervals")
xlabel("Date")
ylabel("Duration (days)")
ylim([0 (max(timeBetweenAccess(:,1)) + 2)])
