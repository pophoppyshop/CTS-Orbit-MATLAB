% Make sure you have Setup.m in the same folder
Setup;

% 360 view ----------------
view360 = conicalSensor(allConsts, 'Name', "360View", MaxViewAngle=179); % yaw, pitch, roll

ac = access(view360, CtS);

accCount360 = accessStatus(ac);
% --------------------------

accessSize = size(accCount); % [rows cols]
occultations = NaN(accessSize(1,2), 1);
occultationLatLon = NaN(accessSize(1,2), 2);

% Iterate through each element
for i = 1:accessSize(1,1)
    for j = 1:accessSize(1,2)
        currentCount = sum(accCount(:,j));

        % Prevents error at the end
        if (j == accessSize(1,2))
            continue
        end
    
        % Check if current count is atleast 5 and next count decreased for
        % both satellite view and 360 view
        if (currentCount >= 5 && accCount(i,j) == 1 && accCount(i, j + 1) == 0 && ...
                accCount360(i, j) == 1 && accCount360(i, j + 1) == 0)
            CtSLatLon = states(CtS, timeIntervals(i, 1), "CoordinateFrame", "geographic");
            otherLatLon = states(allConsts(1, i), "CoordinateFrame", 'geographic');

            % acos(r / distance from center to CtS)
            occultAngle = acos(earthRadius / (CtSLatLon(3, 1) + earthRadius));

            % Get angle difference from CtS to constellation sat
            angleDiff = [otherLatLon(1) - CtSLatLon(1, 1),  otherLatLon(2) - CtSLatLon(2, 1)];
            angleMagnitude = norm(angleDiff);

            % Get lat and lon of occultation
            occultationLatLon(j, 1) = occultAngle * (angleDiff(1) / angleMagnitude) + CtSLatLon(1,1);
            occultationLatLon(j, 2) = occultAngle * (angleDiff(2) / angleMagnitude) +  CtSLatLon(2,1);

            % Add to number of occultations
            if isnan(occultations(j, 1))
                occultations(j, 1) = 1;
            else
                occultations(j, 1) = occultations(j, 1) + 1;
            end
        end
    end
end

occultationLatLon = occultationLatLon(all(~isnan(occultationLatLon), 2), :);

% Plot positions of occultations
figure 
scatter(occultationLatLon(:,2), occultationLatLon(:,1))
xlabel('Longitude (deg)');
ylabel('Latitude (deg)');
title('Longitude and Latitudes of Occultations');
grid on;

% Plot number of occultations over time
figure 
plot(timeIntervals(:,1), occultations(:,1))
xlabel('Time (UTC)');
ylabel('Number of Occultation');
ylim([0 7])
title('Number of Occultations Over Time');
grid on;

% Remove NaN values
occultations = occultations(~isnan(occultations));

percentOccults = numel(occultations) / accessSize(1,2);

%clearvars -except percentOccults


