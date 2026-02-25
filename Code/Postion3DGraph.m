% Make sure you have Setup.m in the same folder
Setup;

% Filter for counts under 4
accCount(accCount >= 4, 1) = NaN;

countSize = numel(accCount);

accPos = NaN(countSize, 3);

% Get all xyz positions for each sample time
for i = 1:countSize
    % Only get info if needed (runs faster)
    if ~isnan(accCount(i))
        pos = states(CtS, timeIntervals(i, 1), "CoordinateFrame", "ecef");

        pos = transpose(pos);

        accPos(i, :) = pos(1, :);
    end
end

% Access counts below 5 in 3D space
figure
scatter3(accPos(:, 1), accPos(:, 2), accPos(:, 3))
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Positions With Satellite Access Count Below 4');
grid on;

%play(sc);              Uncomment to run sim