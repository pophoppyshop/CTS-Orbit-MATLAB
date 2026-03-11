clear
close all

% SOME ISSUES:
% Calculating current true anomaly is not accurate!
% Consider splitting the time interval into orbital periods so we know
% true anomaly will be the same


TOTAL_TIME_HR = 8760;
ONE_ITERATION_HR = 10;    % Will be multiplied by the period of sat (n orbits)
SAMPLE_TIME = 0.5;        % determines length of time intervals (seconds)
OUTPUT_FILE = "DurationsTable_1YR_Test.csv";
START_DATE = datetime(2025,3,24,0,0,0);     % Initial value

initialTableSize = 30;      % can adjust to speed up program

% Initial orbital elements
semiMajorAxis = 6950440;
eccentricity = 1e-6;
inclination = 98; 
RAANi = 135.58;                         
argOfPeriapsis = 0;
trueAnomaly = 1.81165e-15;              

% Init scenario
sc = satelliteScenario(START_DATE,START_DATE,SAMPLE_TIME);

% Rothney station
gs = groundStation(sc, Name="Rothney Station", Latitude=50.868, Longitude=-114.291);

% Initialize CtS satellite with updated orbit parameters
CtS = satellite(sc, semiMajorAxis, eccentricity, inclination, ...
RAANi, argOfPeriapsis, trueAnomaly, Visual3DModel="NarrowBodyAirliner.glb", ...
Name="CtS", OrbitPropagator="two-body-keplerian");

ONE_ITERATION_HR = (CtS.orbitalElements.Period / 3600) * ONE_ITERATION_HR;

% Conical sensor   
camSensor = conicalSensor(CtS, 'Name', "Antenna", MaxViewAngle=7, MountingAngles=[0;0;0]); % yaw, pitch, roll
ac = access(camSensor, gs);

% Visualize field of view of sensor
% satelliteScenarioViewer(sc);     Uncomment to show simulation
fieldOfView(camSensor);

% Holds all durations and start date
durations = table('Size', [initialTableSize, 2], 'VariableTypes', ...
    {'datetime', 'int8'}, 'VariableNames', {'Start Date (UTC)', 'Duration (s)'});
currentIndex = 1;

% Set up containers for data
currentCell = {};

for i = 0:round(TOTAL_TIME_HR / ONE_ITERATION_HR)
    % Update time interval
    currentDate = START_DATE + i * hours(ONE_ITERATION_HR);    
    stopTime = currentDate + hours(ONE_ITERATION_HR);

    sc.StartTime = currentDate;
    sc.StopTime = stopTime;

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

                currentCell = {currentDate + seconds(j * SAMPLE_TIME), 1};

            % Add to current duration
            else
                currentCell{1, 2} = currentCell{1, 2} + 1;
            end
        end
    end

    % Add last cell to durations if possible
    if (numel(currentCell) ~= 0)
        durations(currentIndex, :) = currentCell;
    end
end

% Removes all missing entries
durations = durations(~ismissing(durations(:,1)), :); 

% Only write if there is atleast one entry
if (numel(durations) ~= 0)
    writetable(durations, OUTPUT_FILE);
end