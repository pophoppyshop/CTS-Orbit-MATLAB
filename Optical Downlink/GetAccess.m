clear
close all

% SOME ISSUES:
% Calculating current true anomaly is not accurate!
% Consider splitting the time interval into orbital periods so we know
% true anomaly will be the same

TOTAL_TIME_HR = 8760;
ONE_ITERATION_HR = 20;
SAMPLE_TIME = 0.5;        % determines length of time intervals (seconds)
OUTPUT_FILE = "DurationsTable_1YR_Test.csv";
START_DATE = datetime(2025,3,24,0,0,0);  % Initial value

initialTableSize = 30;      % can adjust to speed up program

% Initial orbital elements
semiMajorAxis = 6950440;
eccentricity = 1e-6;
inclination = 98; 
RAANi = 135.58;                         
argOfPeriapsis = 0;
trueAnomaly = 1.81165e-15;              % Will change during orbit

% Visualize field of view of sensor (Uncomment to open simulation)
% satelliteScenarioViewer(sc);     
% fieldOfView(camSensor);

parfor i = 0:(TOTAL_TIME_HR / ONE_ITERATION_HR)
    % Init scenario
    currentDate = START_DATE + i * hours(ONE_ITERATION_HR);    % One iteration in hours
    stopTime = currentDate + hours(ONE_ITERATION_HR);
    sc = satelliteScenario(currentDate,stopTime,SAMPLE_TIME);

    % Rothney station
    gs = groundStation(sc, Name="Rothney Station", Latitude=50.868, Longitude=-114.291);

    % Get the current true anomaly
    [r, v] = propagateOrbit(currentDate, semiMajorAxis, eccentricity, ...
                inclination, RAANi, argOfPeriapsis, trueAnomaly);
        
    [a, ecc, incl, RAAN, argp, nu, truelon, arglat, lonper] = ijk2keplerian(r,v);

    % Initialize CtS satellite with updated orbit parameters
    CtS = satellite(sc, semiMajorAxis, eccentricity, inclination, ...
    RAANi, argOfPeriapsis, nu, Visual3DModel="NarrowBodyAirliner.glb", ...
    Name="CtS", OrbitPropagator="two-body-keplerian");
    
    % Conical sensor   
    camSensor = conicalSensor(CtS, 'Name', "Antenna", MaxViewAngle=7, MountingAngles=[0;0;0]); % yaw, pitch, roll
    ac = access(camSensor, gs);

    % 1 x num of time intervals, contains boolean values
    accessIntervals = accessStatus(ac);
    accessSize = numel(accessIntervals);

    % Set up containers for data
    currentCell = {};
    tempData = table('Size', [initialTableSize, 2], 'VariableTypes', ...
    {'datetime', 'int8'}, 'VariableNames', {'Start Date (UTC)', 'Duration (s)'});
    currentIndex = 1;

    % Add all durations
    for j = 1:accessSize
        % If current entry is true
        if accessIntervals(j) && j > 1
            % If previous entry is false, start new duration
            if ~accessIntervals(j - 1)
                
                % Add any previous cell
                if numel(currentCell) ~= 0
                    tempData(currentIndex, :) = currentCell;

                    currentIndex = currentIndex + 1;
                end

                currentCell = {currentDate + seconds(j * SAMPLE_TIME), 1};

            % Add to current duration
            else
                currentCell{1, 2} = currentCell{1, 2} + 1;
            end
        end
    end

    % Add last cell to durations if possible
    if (numel(currentCell) ~= 0)
        tempData(currentIndex, :) = currentCell;
    end

    % Removes all missing entries
    tempData = tempData(~ismissing(tempData(:,1)), :);

    % Only write if there is atleast one entry
    if (numel(tempData) ~= 0)
        writetable(tempData, OUTPUT_FILE, 'WriteMode', 'append');
    end
end


%{
% Convert to seconds
durations(:,2) = durations(:,2) .* SAMPLE_TIME;

% Get average duration
meanDuration = sum(durations(1:currentIndex, 2));
meanDuration = meanDuration{1,1} / currentIndex;



% Save the durations table to a CSV file
writetable(durations(1:currentIndex, :), OUTPUT_FILE);

table('Size', [100, 2], 'VariableTypes', ...
    {'datetime', 'int8'}, 'VariableNames', {'Start Date (UTC)', 'Duration (s)'})
%}






