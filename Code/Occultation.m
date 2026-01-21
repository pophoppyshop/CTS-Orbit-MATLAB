% Make sure you have Setup.m in the same folder
Setup;

countSize = numel(accCount);
occultations = NaN(countSize, 1);

for i = 1:countSize
    current = accCount(i);

    % Prevents error at the end
    if (i == countSize)
        continue
    end

    % Check if current count is atleast 5 and next count decreased
    % (setting/occulting)
    if (current >= 5 && accCount(i + 1) < current)
        % Get number of satellites occulting
        occultations(i, 1) = current - accCount(i + 1);
    end
end

figure 
plot(timeIntervals(:,1), occultations(:,1))
xlabel('Time (UTC)');
ylabel('Number of Occultation');
ylim([0 7])
title('Number of Occultations Over Time');
grid on;

% Remove NaN values
occultations = occultations(~isnan(occultations));

percentOccults = numel(occultations) / countSize;

clearvars -except percentOccults


