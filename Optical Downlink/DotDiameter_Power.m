clear
close all

% Plot altitude vs dot diameter
altitudes = 0:0.1:600;
dotDiameters =  2 * tand(7/2) * altitudes;

plot(altitudes(1,:), dotDiameters(1,:))
title("Altitude Vs Dot Diameter")
xlabel("Altitude (km)")
ylabel("Dot Diameter (km)")

% Plot each output power curve
figure
hold on

inputPower = 10:10:100; 

for power = inputPower
    outputPower = (power * 0.6 * 0.2 ^ 2) ./ (dotDiameters*1000.^2);
    
    plot(altitudes(1,:), outputPower(1,:))
end

title("Altitudes Vs Output Power for Different Input Power")
ylim([0 2*10^-7])
ylabel("Output Power (W)")
xlabel("Altitudes (km)")

leg = legend(string(inputPower) + " W");
title(leg, "Input power")

% Plot each power fraction graph
figure
hold on

powerFraction = (0.6 * 0.2 ^ 2) ./ (dotDiameters*1000.^2);

plot(altitudes(1,:), powerFraction(1,:))
title("Altitudes Vs P_r_x / P_t_x")
ylim([0 0.5*10^-8])
ylabel("P_r_x / P_t_x")
xlabel("Altitudes (km)")


%{
% Init scenario
startTime = datetime(2025,2,1,0,0,0);
stopTime = startTime + hours(2/60);
sampleTime = 10;    % determines length of time intervals (seconds)

% Initialize CtS satellite with orbit parameters
semiMajorAxis = 6950;
eccentricity = 1e-6;
inclination = 98;
RAAN = 135.58;
argOfPeriapsis = 0;
trueAnomaly = 1.81165e-15;
A = 0.115 * 0.115;
cd = 2; %coefficient of drag
mass = 5;
F107 = 70; %solar radio flux
Ap = 0;

Re = 6378.137;      
Mu = 398600.4418;

computeOrbitalDecay();

[P, t] = computeOrbitalDecay(semiMajorAxis, eccentricity, A, cd, mass, F107, Ap);

figure('color',[1 1 1]);
plot(t./86400,((P./(2.*pi)).^2.*Mu).^(1/3)-Re,'k','linewidth',2);
grid on;
xlabel('Time (Days)');
ylabel('Altitude (km)');
title(['Vectorized Orbital Decay vs. Time ','A*C_D = ',num2str(A*cd)]);
ylim([180 max(semiMajorAxis-Re)]);
[P,t] = deal([]);

%}