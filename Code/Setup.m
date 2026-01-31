%% 
clear
close all;

% Init scenario
startTime = datetime(2025,2,1,0,0,0);
stopTime = startTime + hours(168);
sampleTime = 10;    % determines length of time intervals (seconds)
sc = satelliteScenario(startTime,stopTime,sampleTime);

% Initialize CtS satellite with orbit parameters
semiMajorAxis = 6950440;
eccentricity = 1e-6;
inclination = 98;
RAAN = 135.58;
argOfPeriapsis = 0;
trueAnomaly = 1.81165e-15;

CtS = satellite(sc, semiMajorAxis, eccentricity, inclination, ...
    RAAN, argOfPeriapsis, trueAnomaly, Visual3DModel="NarrowBodyAirliner.glb");

% Initialize constellations
glo = satellite(sc, "/MATLAB Drive/CtS/Orbit Sims/CTS-Orbit-MATLAB/XML/glo.xml");
gps = satellite(sc, "/MATLAB Drive/CtS/Orbit Sims/CTS-Orbit-MATLAB/XML/gps.xml");
beidou = satellite(sc, "/MATLAB Drive/CtS/Orbit Sims/CTS-Orbit-MATLAB/XML/beidou.xml");
galileo = satellite(sc, "/MATLAB Drive/CtS/Orbit Sims/CTS-Orbit-MATLAB/XML/galileo.xml");

% Remove satellites if not testing them
allConsts = [glo gps];

% Rothney ground station
name = "Rothney";
lat = dms2degrees([50 52 05.3]);
lon = dms2degrees([-114 17 28.1]);

gs = groundStation(sc,"Name",name,"Latitude",lat, "Longitude", lon);

% Conical sensor   
camSensor = conicalSensor(CtS, 'Name', "Antenna", MaxViewAngle=100, MountingAngles=[0;-85;0]); % yaw, pitch, roll

% Visualize field of view of sensor
satelliteScenarioViewer(sc);               %Uncomment to run sim
fieldOfView(camSensor);

% Get number of accessed satellites in each sample time
accCount = accessStatus(access(camSensor, allConsts));

% Collapse into one row by adding (Commented out ONLY for testing Error.m & Occulation.m)
%accCount = sum(accCount, 1);
%accCount = transpose(accCount);

% All sample time intervals for sim
timeIntervals = startTime : seconds(sampleTime) : stopTime;
timeIntervals = transpose(timeIntervals);