close all
clear

SAMPLE_TIME = 0.5;

durations = readtable("DurationsTable_1YR_results.csv");

% Convert to seconds
durations(:,2) = durations(:,2) .* SAMPLE_TIME;

scatter(durations{:, 1}, durations{:,2})
title("Durations of access intervals over a year")
xlabel("Date (UTC)")
ylabel("Duration (s)")
xlim([datetime(2025,3,24,0,0,0) datetime(2026,3,24,0,0,0)])
ylim([0 (max(durations{:,2}) + 2)])

% Get average duration
meanDuration = mean(durations(:,2));

rows = size(durations, 1);

% Get time between access intervals (days)
timeBetweenAccess = table('Size', [rows - 1, 2], 'VariableTypes', ...
    {'datetime', 'int16'}, 'VariableNames', {'Start Date (UTC)', 'Duration (s)'});

for i = 1:(rows - 1)
    difference = durations(i + 1, 1) - durations(i, 1);

    currentCell = {durations{i,1}, days(difference{1,1})};

    timeBetweenAccess(i, :) = currentCell;
end

avgTimeBetween = mean(timeBetweenAccess);    % in days

% Time between access Vs start date
figure
scatter(timeBetweenAccess{:,1}, timeBetweenAccess{:,2})
title("Time Between Access Intervals")
xlabel("Start date (UTC)")
ylabel("Duration (days)")
xlim([datetime(2025,3,24,0,0,0) datetime(2026,3,24,0,0,0)])
ylim([0 (max(timeBetweenAccess{:,2}) + 2)])

% Time between access Vs
