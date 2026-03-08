function [ac, CtS] = AddSatellite(sc, semiMajorAxis, eccentricity, inclination, ...
RAAN, argOfPeriapsis, trueAnomaly, gs)
% AddSatelite()
% Adds a satellite object to the scenario and a conical sensor to the
% satellite. Returns the access and satellite objects.
arguments(Input)
    sc
    semiMajorAxis
    eccentricity
    inclination
    RAAN
    argOfPeriapsis
    trueAnomaly
    gs
end

arguments(Output)
    ac
    CtS
end

% Initialize CtS satellite with orbit parameters
CtS = satellite(sc, semiMajorAxis, eccentricity, inclination, ...
RAAN, argOfPeriapsis, trueAnomaly, Visual3DModel="NarrowBodyAirliner.glb", ...
Name="CtS", OrbitPropagator="two-body-keplerian");

% Conical sensor   
camSensor = conicalSensor(CtS, 'Name', "Antenna", MaxViewAngle=7, MountingAngles=[0;0;0]); % yaw, pitch, roll
ac = access(camSensor, gs);

end