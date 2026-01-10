% Make sure you have Setup.m in the same folder
Setup;

simulationSteps = numel(timeIntervals);

% Get constellation positions and velocities
numSats = numel(sc.Satellites);
allSatPos = zeros(numSats, 3, simulationSteps);
allSatVel = zeros(numSats, 3, simulationSteps);

for i = 1:numSats
    [oneSatPos, oneSatVel] = states(sc.Satellites(i), "CoordinateFrame", "ecef");
    allSatPos(i, :, :) = permute(oneSatPos, [3 1 2]);
    allSatVel(i, :, :) = permute(oneSatVel, [3 1 2]);
end

% Get all CtS sat positions



% Get all pseudoranges and pseudorange rates for each sample time
allP = zeros(numSats, simulationSteps);

for i = 1:simulationSteps
    [pos] = states(CtS, timeIntervals(i, 1), "CoordinateFrame", "ecef");

    pos = transpose(pos);

    satPos = allSatPos(:, :, i);

    allP(:,i) = pseudoranges(pos, satPos);
end

% Estimate satellite position with pseudo variables
recPos = receiverposition(allP(accCount), );
