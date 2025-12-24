clear
close all;

% Init scenario
startTime = datetime(2025,2,1,0,0,0);
stopTime = startTime + hours(168);
sampleTime = 60;    % determines length of time intervals (seconds)
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
const1 = satellite(sc, "XML/glo.xml");
const2 = satellite(sc, "XML/gps.xml");

% Rothney ground station
name = "Rothney";
lat = dms2degrees([50 52 05.3]);
lon = dms2degrees([-114 17 28.1]);

gs = groundStation(sc,"Name",name,"Latitude",lat, "Longitude", lon);

% Conical sensor                               
g = gimbal(CtS);    
camSensor = conicalSensor(g, MaxViewAngle=100, MountingAngles=[0;-85;0]); % yaw, pitch, roll

ac = access(camSensor, const1);
ac2 = access(camSensor, const2);

% Visualize field of view of sensor
%satelliteScenarioViewer(sc);               Uncomment to run sim
fieldOfView(camSensor);

% Get number of accessed satellites in each sample time
accCount = accessStatus(ac);
accCount = [accCount; accessStatus(ac2)];

% Collapse into one row by adding
accCount = sum(accCount, 1);
accCount = transpose(accCount);

% All sample time intervals for sim
timeIntervals = startTime : seconds(sampleTime) : stopTime;
timeIntervals = transpose(timeIntervals);