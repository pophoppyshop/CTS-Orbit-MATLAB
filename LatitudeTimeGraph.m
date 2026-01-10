% Make sure you have Setup.m in the same folder
Setup;

% Average and standard deviation
average = mean(accCount(:, 1), 'omitnan');
standardDev = std(accCount(:, 1), 'omitnan');

% Access count VS time
figure
plot(timeIntervals(:,1), accCount(:,1))
xlabel('Time (UTC)');
ylabel('Access Count');
title('Satellite Access Count Over Time');
grid on;

% Filter for counts under 5 (comment this if no filter)
accCount(accCount >= 5, 1) = NaN;

countSize = numel(accCount);

% Get all latitudes for each sample time
accLat = NaN(countSize, 1);

for i = 1:countSize
    % Only get info if needed (runs faster)
    if ~isnan(accCount(i))
        lonlat = states(CtS, timeIntervals(i, 1), "CoordinateFrame", "geographic");
    
        accLat(i) = lonlat(1);
    end
end

% Access count VS latitude
figure
scatter(accLat(:,1), accCount(:,1), "o")
xlim([-100 100])
ylim([5 35])
xlabel('Latitude (degrees)');
ylabel('Access Count');
title('Satellite Access Count Below 5 VS Latitude');
grid on;

clearvars -except average standardDev

%play(sc);              Uncomment to run sim