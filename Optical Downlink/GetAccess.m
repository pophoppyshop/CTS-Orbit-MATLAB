clear
close all

TOTAL_TIME_HR = 8760;
ONE_ITERATION_HR = 21;
sampleTime = 0.5;        % determines length of time intervals (seconds)
currentDate = datetime(2025,3,24,0,0,0); % Initial value is start

semiMajorAxis = 6950440;
eccentricity = 1e-6;
inclination = 98; 
RAAN = 135.58;
argOfPeriapsis = 0;
trueAnomaly = 1.81165e-15; % Will change during orbit

% 1st column contains date, 2nd contains duration
durations = table('Size', [100, 2], 'VariableTypes', ...
    {'datetime', 'int8'}, 'VariableNames', {'Date (UTC)', 'Duration (30s)'});


currentCell = {};
currentCellDate = datetime(2025,3,24,0,0,0);
currentIndex = 1;

for i = 0:1:(TOTAL_TIME_HR / ONE_ITERATION_HR)
    % Init scenario
    stopTime = currentDate + hours(ONE_ITERATION_HR);
    sc = satelliteScenario(currentDate,stopTime,sampleTime);

    % Initialize CtS satellite with orbit parameters
    CtS = satellite(sc, semiMajorAxis, eccentricity, inclination, ...
    RAAN, argOfPeriapsis, trueAnomaly, Visual3DModel="NarrowBodyAirliner.glb", ...
    Name="CtS", OrbitPropagator="two-body-keplerian");

    % Conical sensor   
    camSensor = conicalSensor(CtS, 'Name', "Antenna", MaxViewAngle=7, MountingAngles=[0;0;0]); % yaw, pitch, roll
    
    % Visualize field of view of sensor
    %satelliteScenarioViewer(sc);               % Uncomment to run sim
    fieldOfView(camSensor);
    
    % Rothney station
    gs = groundStation(sc, Name="Rothney Station", Latitude=50.868, Longitude=-114.291);
    ac = access(camSensor, gs);

    % 1 x num of time intervals, contains boolean values
    accessIntervals = accessStatus(ac);
    accessSize = numel(accessIntervals);

    % Add all durations
    for j = 1:accessSize
        % If current entry is true
        if accessIntervals(j) && j > 1
            % If previous entry is false, start new duration
            if ~accessIntervals(j - 1)
                % Add any previous cell
                if numel(currentCell) ~= 0
                    durations(currentIndex, :) = currentCell;

                    currentIndex = currentIndex + 1;
                end

                currentCell = {currentDate + seconds(j * sampleTime), 1};
            % Add to current duration
            else
                currentCell{1, 2} = currentCell{1, 2} + 1;
            end
        end
    end

    currentDate = currentDate + seconds(accessSize);

    % Update true anomaly
    elements = orbitalElements(CtS);

    trueAnomaly = elements.TrueAnomaly;
end

% Last check to add cell to durations
durations(currentIndex, :) = currentCell;





