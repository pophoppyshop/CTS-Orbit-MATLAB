SAMPLE_TIME = 0.5;

durations = readtable("DurationsTable_1YR_Test.csv");

% Convert to seconds
durations(:,2) = durations(:,2) .* SAMPLE_TIME;

scatter(durations(:, 1), durations(:,2))
title("Durations of access intervals over a year")
xlabel("Date")
ylabel("Duration (s)")

% Get average duration
meanDuration = mean(durations(:,2));

rows = size(durations, 1);

% Get time between access intervals (days)
timeBetweenAccess = zeros(rows - 1, 1);

for i = 1:(rows - 1)
    timeBetweenAccess(i, 1) = days(durations(i + 1, 1) - durations(i, 1));
end

avgTimeBetween = mean(timeBetweenAccess);    % in days