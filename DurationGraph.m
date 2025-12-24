% Make sure you have Setup.m in the same folder
Setup;

% Filter for counts under 5
accCount(accCount >= 5, 1) = NaN;

countSize = numel(accCount);

% Contains durations of counts below 5
% 1st col is start sample time, 2nd col contains duration
durations = NaN(countSize, 1);
current = NaN;
old = NaN;
startIndex = 1;     % Start time for each interval

for i = 1:countSize
    current = accCount(i);

    if ~isnan(current)
        if isnan(old)
            % Start new count for an interval
            startIndex = i;
            
            durations(i, 1) = 1;
        else
            % Add to current interval count
            durations(startIndex, 1) = durations(startIndex, 1) + 1;
        end
    end

    old = current;
end

% Get all latitudes for each sample time
accLat = NaN(countSize, 1);

for i = 1:countSize
    % Only get info if needed (runs faster)
    if ~isnan(durations(i))
        lonlat = states(CtS, timeIntervals(i, 1), "CoordinateFrame", "geographic");

        accLat(i) = lonlat(1);
    end
end

% Convert the number of time samples to minutes
durations = (sampleTime / 60) * durations;

% Access count VS latitude
figure
scatter(accLat(:,1), durations(:,1), "o")
xlim([-100 100])
ylim([0 9])
xlabel('Latitude (degrees)');
ylabel('Duration of intervals (minutes)');
title('Duration of Intervals Where Satellite Count is Below 5 VS Latitude');
grid on;

average = mean(durations(:, 1), 'omitnan');
standardDev = std(durations(:, 1), 'omitnan');

clearvars -except average standardDev