close all
clear

PtxWatts = 10;
PreqWatts = 0.166e-12;
Preq = -10 * log10(PreqWatts/0.001); % Required signal power to achieve specific BER in dBm
Ptx = 10 * log10(PtxWatts/0.001);   % Transmitted power in dBm 

linkMargins = zeros(size(0:0.5:45, 1), 2);
index = 1;

for i = 0:0.5:45
    % Configure the ground station, satellites, and link characteristics
    % Set the ground station characteristics with parabolic telescope
    gs = struct;
    gs.Height = 1;                % Height above the mean sea level in km
    gs.OpticsEfficiency = 0.8;    % Optical antenna efficiency
    gs.ApertureDiameter = 0.2;      % Antenna aperture diameter in m
    gs.PointingError = 1e-6;      % Pointing error in rad
    
    % Set the satellite A characteristics with parabolic telescope
    satA = struct;
    satA.Height = 550;            % Height above the mean sea level in km
    satA.OpticsEfficiency = 0.8;  % Optical antenna efficiency
    satA.ApertureDiameter = 0.2; % Antenna aperture diameter in m
    satA.PointingError = 1e-6;    % Pointing error in rad
    
    % satellite A to ground station
    tx = satA;
    rx = gs;
    
    % Set the link characteristics
    link = struct;
    link.Wavelength = 825e-9;    % m
    link.TroposphereHeight = 11;  % km (Typically ranges from 6-20 km)
    link.ElevationAngle = 90 - i;     % degrees (assume directly above)
    link.Type = "downlink";       % "downlink"|"inter-satellite"|"uplink"
    
    % When the Type field is set to "uplink" or "downlink", you must specify
    % the CloudType field, as defined in [5] table 1
    link.CloudType = "Thin cirrus";
    link.AttenuationType = "fog"; % "fog"|"rain"|"snow"
    
    % Calculate transmitter and receiver gain
    txGain = (pi*tx.ApertureDiameter/link.Wavelength)^2;
    Gtx = 10*log10(txGain); % in dB
    rxGain = (pi*rx.ApertureDiameter/link.Wavelength)^2;
    Grx = 10*log10(rxGain); % in dB
    
    % Calculate transmitter and receiver pointing loss in dB
    txPointingLoss = 4.3429*(txGain*(tx.PointingError)^2);
    rxPointingLoss = 4.3429*(rxGain*(rx.PointingError)^2);
    
    absorptionLoss = 0.8; % Absorption loss in dB from Figure 2
    
    % Calculate the distance of the optical beam that propagates through
    % the troposphere layer of the atmosphere in km
    dT = (link.TroposphereHeight - gs.Height).*cscd(link.ElevationAngle);
    
    % Calculate the slant distance for uplink and downlink between
    % satellite A and the ground station for circular orbit in m
    dGS = slantRangeCircularOrbit(link.ElevationAngle,satA.Height*1e3,gs.Height*1e3);
    
    % Calculate free-space path loss between the ground station and
    % satellite in dB
    pathLoss = fspl(dGS,link.Wavelength);
    
    % Calculate loss due to geometrical scattering
    % cnc - cloud number concentration in cm-3
    % lwc - Liquid water content in g/m-3
    [cnc,lwc] = getCloudParameters(link.CloudType);
    visibility = 1.002/((lwc*cnc)^0.6473);                   % Calculate visibility in km
    
    if link.AttenuationType=="fog"
        % Get particle size related coefficient
        if visibility<=0.5
            delta = 0;
        elseif visibility>0.5 && visibility<=1
            delta = visibility - 0.5;
        elseif visibility>1 && visibility<=6
            delta = 0.16*visibility + 0.34;
        elseif visibility>=6 && visibility<=50
            delta = 1.3;
        else                                                     % visibility>50
            delta = 1.6;
        end
    
        geoCoeff = (3.91/visibility)* ...
            ((link.Wavelength*1e9/550)^-delta);                  % Extinction coefficient
    elseif link.AttenuationType=="rain"
        geoCoeff = 2.8/visibility;
    else % link.AttenuationType = "snow"
        geoCoeff = 58/visibility;
    end
    
    geoScaLoss = 4.3429*geoCoeff*dT;                         % Geometrical scattering loss in dB
    
    % Calculate loss due to Mie scattering
    lambda_mu = link.Wavelength*1e6;                         % Wavelength in microns
    
    % Calculate empirical coefficients
    a = (0.000487*(lambda_mu^3)) - (0.002237*(lambda_mu^2)) + ...
        (0.003864*lambda_mu) - 0.004442;
    b = (-0.00573*(lambda_mu^3)) + (0.02639*(lambda_mu^2)) - ...
        (0.04552*lambda_mu) + 0.05164;
    c = (0.02565*(lambda_mu^3)) - (0.1191*(lambda_mu^2)) + ...
        (0.20385*lambda_mu) - 0.216;
    d = (-0.0638*(lambda_mu^3)) + (0.3034*(lambda_mu^2)) - ...
        (0.5083*lambda_mu) + 0.425;
    
    mieER = a*(gs.Height^3) + b*(gs.Height^2) + ...
        c*(gs.Height) + d;                                       % Extinction ratio
    
    mieScaLoss = (4.3429*mieER)./sind(link.ElevationAngle);  % Mie scattering loss in dB
    
    % Calculate link margin for uplink or downlink in dB
    linkMargin = Ptx + 10*log10(tx.OpticsEfficiency) + ...
        10*log10(rx.OpticsEfficiency) + Gtx + Grx - ...
        txPointingLoss - rxPointingLoss - pathLoss - ...
        absorptionLoss - geoScaLoss - mieScaLoss - Preq;
    
    %disp("Link margin for "+num2str(link.Type)+" is "+num2str(linkMargin)+" dB")
    linkMargins(index,1) = i;
    linkMargins(index, 2) = linkMargin;

    index = index + 1;
end

% Plot Elevation Angle Vs Link Margin
plot(90 - linkMargins(:, 1), linkMargins(:, 2))
title("Elevation Angle Vs Link Margin")
xlabel("Elevation angle in degrees")
ylabel("Link margin in db")

function [cnc,lwc] = getCloudParameters(cloudType)
% cnc - Cloud number concentration in 1/cm^3
% lwc - Liquid water content g/m^3
switch cloudType
    case "Cumulus"
        cnc = 250;
        lwc = 1;
    case  "Stratus"
        cnc = 250;
        lwc = 0.29;
    case "Stratocumulus"
        cnc = 250;
        lwc = 0.15;
    case "Altostratus"
        cnc = 400;
        lwc = 0.41;
    case "Nimbostratus"
        cnc = 200;
        lwc = 0.65;
    case "Cirrus"
        cnc = 0.025;
        lwc = 0.06405;
    case "Thin cirrus"
        cnc = 0.5;
        lwc = 3.128*1e-4;
end
end