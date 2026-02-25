% Make sure you have Setup.m in the same folder
Setup;

simulationSteps = numel(timeIntervals);

% Get constellation positions and velocities
numSats = numel(sc.Satellites);
allSatPos = zeros(numSats - 1, 3, simulationSteps);

% Start at 2 to ignore CtS
for i = 2:numSats
    index = i - 1;

    [oneSatPos, oneSatVel] = states(sc.Satellites(i), "CoordinateFrame", "ecef");
    allSatPos(index, :, :) = permute(oneSatPos, [3 1 2]);
end

% Get all CtS sat positions
all_CtS_Pos = states(CtS, "CoordinateFrame", "ecef");

% Get all pseudoranges and pseudorange rates for each sample time
allP = zeros(numSats - 1, simulationSteps);
estRecLLA = zeros(simulationSteps, 3);

for i = 1:simulationSteps
    % Current CtS latitude, longitude, altitude
    ctsLLA = all_CtS_Pos(:, i);
    ctsLLA = transpose(ctsLLA);
    ctsLLA = ecef2lla(ctsLLA);

    satPos = allSatPos(:, :, i);

    allP(:,i) = pseudoranges(ctsLLA, satPos);
end

% Estimate the CtS position using pseudoranges
for i = 1:simulationSteps
    p = allP(:, i);
    satPos = allSatPos(:, :, i);
    isSatVisible = accCount(:, i);

    estRecLLA(i,:) = receiverposition(p(isSatVisible, :), satPos(isSatVisible, :));
end

all_CtS_Pos = transpose(all_CtS_Pos);
estPos = lla2ecef(estRecLLA);

% Graph error VS time
winSize = floor(size(estPos,1)/10);

figure
processedData = smoothdata(abs(estPos-all_CtS_Pos),"movmedian",winSize);

plot(timeIntervals(:,1), processedData)
ylim([1 3])
legend("x","y","z")
xlabel("Time (s)")
ylabel("Error (m)")
title("Errors in Satellite Position Over Time")

% Get all latitudes for each sample time-
countSize = numel(timeIntervals);
accLat = NaN(countSize, 1);
latlon = states(CtS, "CoordinateFrame", "geographic");

for i = 1:countSize
    accLat(i) = latlon(1,i);
end

% Graph error VS latitude
figure
plot(accLat(:,1), processedData)
ylim([1 3])
legend("x","y","z")
xlabel("Latitude (degree)")
ylabel("Error (m)")
title("Errors in Satellite Position Over Latitudes")

% Calculate averages and standard deviations
xAverage = mean(processedData(:, 1), 'omitnan');
yAverage = mean(processedData(:, 2), 'omitnan');
zAverage = mean(processedData(:, 3), 'omitnan');

xStandardDev = std(processedData(:, 1), 'omitnan');
yStandardDev = std(processedData(:, 2), 'omitnan');
zStandardDev = std(processedData(:, 3), 'omitnan');

clearvars -except xAverage yAverage zAverage xStandardDev yStandardDev zStandardDev
