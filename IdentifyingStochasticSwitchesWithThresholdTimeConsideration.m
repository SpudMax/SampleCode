% % % % May need to re-evaluate how long I expect a trajectory to hold a
% value, especially for higher frequency events
tic;
numberOfSwitchingEventsPerTrajectory = zeros(nTraj+1,4);
numberOfSwitchingEventsPerTrajectoryBurnedTime = zeros(nTraj+1, 4);

resetIfFailedToHold = true;
errorMargin = 2.5;
rollingAvgTime = 100; 
edgeTimeRequirement = 10; % Higher value means lower "detections" (200-400)
timeStepsBurnedFromTrajectory = 1000; % 1000 time steps = 100 seconds (step size is 0.1)

% Target switching edge
targetValue = 35;

% Target "range"
detectionThresholdMin = 15;
detectionThresholdMax = 50;


% initializing vectors for storing rolling average of each species
rollingAvgStoreA = zeros(nTraj, length(nTraj)/deltaTime);
rollingAvgStoreB = zeros(nTraj, length(nTraj)/deltaTime);

% initializing vectors for storing switching events for both comps

allRisingEventsA = zeros(nTraj, 400);
allFallingEventsA = zeros(nTraj, 400);

allRisingEventsB = zeros(nTraj, 400);
allFallingEventsB = zeros(nTraj,400);



mov = VideoWriter('TwoCompStochSimUnbiasedStartVol0P32AVol10BExchRate4e-2Corrected.mp4', 'MPEG-4');
mov.FrameRate = 1; %sets frames/sec
mov.Quality = 100;
open(mov)


figure(16)
xlabel('Time (sec)', 'fontsize', 32)
ylabel('N_{S_2}', 'fontsize', 32)
xlim([0 tMax])
ylim([0 max(nS2AStore, [], 'all')])


set(gcf, 'Position',  [1000, 1000, 2000, 2000])

ax = gca;
ax.TickLength = [0.03 0.03];
ax.LineWidth = 7;
ax.FontSize = 32;

hold on


% Foreach of our trajectories
for i = 1:nTraj
    cla
    hold on
    plot(timeArray, nS2AStore(i,:),'Color', [218,112,214]/255, 'LineWidth', 2)
    plot(timeArray, nS2BStore(i,:), 'Color', [176,196,222]/255, 'LineWidth',2)

	% Define our rolling average value
	rollingAverageA = zeros(rollingAvgTime,1);
    rollingAverageB = zeros(rollingAvgTime,1);

    for k = 1:rollingAvgTime
		rollingAverageA(k) = nS2AStore(i,k);
        rollingAverageB(k) = nS2BStore(i,k);
    end

	% This is our next target edge, rising or falling edge
    if mean(rollingAverageA) <  targetValue
        isRisingA = true;
    else 
        isRisingA = false;
    end

    if mean(rollingAverageB) <  targetValue
        isRisingB = true;
    else 
        isRisingB = false;
    end

	risingDetectionsA = 0;
	fallingDetectionsA = 0;
    risingDetectionsABurnedTime = 0;
    fallingDetectionsABurnedTime = 0;

    risingDetectionsB = 0;
	fallingDetectionsB = 0;
    risingDetectionsBBurnedTime = 0;
    fallingDetectionsBBurnedTime = 0;

    risesA = [];
    fallsA = [];

    risesB = [];
    fallsB = [];

	heldForA = 0;
    heldForB = 0;


    for j = timeStepsBurnedFromTrajectory:length(timeArray)
		rollingAverageA = rollAvg(rollingAverageA, nS2AStore(i,j));
        averageA = mean(rollingAverageA);

        rollingAvgStoreA(i,j) = averageA;

        rollingAverageB = rollAvg(rollingAverageB, nS2BStore(i,j));
        averageB = mean(rollingAverageB);

        rollingAvgStoreB(i,j) = averageB;


%           disp(isRising + ": ("+j+", "+ nS2AStore(i,j) +")")
%          disp(isRising + ": ("+j+", "+ average +")")

		% Rising edge detection
        if(isRisingA) 
            if(averageA > targetValue) 
				heldForA = heldForA + 1; % Detected potential rising event, held for increases

				% Big happies :) We found an edge detection satifying all our conditions
                if(heldForA >= edgeTimeRequirement && averageA > detectionThresholdMax)

					% Reset hold time and flip edge
					heldForA = 0;
					isRisingA = ~isRisingA;

					% Increment our detection
					risingDetectionsA = risingDetectionsA + 1;
                    risesA(risingDetectionsA) = j;
                    xline(risesA(risingDetectionsA)*deltaTime,'Color', [0,0,0]/255 ,'LineWidth', 4)
                    
                    if j > timeStepsBurnedFromTrajectory 
                        risingDetectionsABurnedTime = risingDetectionsABurnedTime + 1;
                    end
                end
            
            else
                if resetIfFailedToHold == true
                    heldForA = 0;  % Reset to zero as the window was missed
                end

                for k = 1 : length(risesA)
                    allRisingEventsA(i,k) = risesA(k) * deltaTime;
                end

            end


		% Falling edge detection
        elseif(~isRisingA) 
            if(averageA < targetValue) 
				heldForA = heldForA + 1; % Detected potential rising event, held for increases
                
                if(heldForA >= edgeTimeRequirement && averageA < detectionThresholdMin) 

					% Reset hold time and flip edge
					heldForA = 0;
					isRisingA = ~isRisingA;

					% Increment our detection
					fallingDetectionsA = fallingDetectionsA + 1;
                    fallsA(fallingDetectionsA) = j;

                    xline(fallsA(fallingDetectionsA)*deltaTime, 'Color', [0,0,0]/255 ,'LineWidth', 4)

                    if j > timeStepsBurnedFromTrajectory
                        fallingDetectionsABurnedTime = fallingDetectionsABurnedTime + 1;
                    end
                end
			
			else 
                if resetIfFailedToHold == true
                    heldForA = 0;  % Reset to zero as the window was missed
                end			

                for k = 1 : length(fallsA)
                    allFallingEventsA(i,k) = fallsA(k) * deltaTime;
                end

            end

        end
                if(isRisingB) 
            if(averageB > targetValue) 
				heldForB = heldForB + 1; % Detected potential rising event, held for increases

				% Big happies :) We found an edge detection satifying all our conditions
                if(heldForB >= edgeTimeRequirement && averageB > detectionThresholdMax)

					% Reset hold time and flip edge
					heldForB = 0;
					isRisingB = ~isRisingB;

					% Increment our detection
					risingDetectionsB = risingDetectionsB + 1;
                    risesB(risingDetectionsB) = j;
                    xline(risesB(risingDetectionsB)*deltaTime, 'Color', [128,128,128]/255 ,'LineWidth', 4)

                    if j > timeStepsBurnedFromTrajectory
                        risingDetectionsBBurnedTime = risingDetectionsBBurnedTime + 1;
                    end
                end
            
            else
                if resetIfFailedToHold == true
                    heldForB = 0;  % Reset to zero as the window was missed
                end

                for k = 1 : length(risesB)
                    allRisingEventsB(i,k) = risesB(k) * deltaTime;
                end

            end   
%             Falling Edge Detection B Comp
        elseif(~isRisingB) 
            if(averageB < targetValue) 
				heldForB = heldForB + 1; % Detected potential rising event, held for increases
                
                if(heldForB >= edgeTimeRequirement && averageB < detectionThresholdMin) 

					% Reset hold time and flip edge
					heldForB = 0;
					isRisingB = ~isRisingB;

					% Increment our detection
					fallingDetectionsB = fallingDetectionsB + 1;
                    fallsB(fallingDetectionsB) = j;

                    xline(fallsB(fallingDetectionsB)*deltaTime,'Color', [128,128,128]/255, 'LineWidth',4)
                    
                     if j > timeStepsBurnedFromTrajectory
                        fallingDetectionsBBurnedTime = fallingDetectionsBBurnedTime + 1;
                    end
                end
			
			else 
                if resetIfFailedToHold == true
                    heldForB = 0;  % Reset to zero as the window was missed
                end			

                for k = 1 : length(fallsB)
                    allFallingEventsB(i,k) = fallsB(k) * deltaTime;
                end

            end

        end
    
    end % foreach point


formatSpec2 = "Tracjectory: %d";
A12 = i;
str2 = sprintf(formatSpec2,A12);
title([str2], 'FontSize', 18)
legend( 'S_{2,A}', 'S_{2,B}', 'Location', 'northeast', 'FontSize', 20, 'NumColumns', 2)



set(gca, 'nextplot', 'replacechildren');
pause(0.3);

frame = getframe(gcf);
writeVideo(mov,frame);
set(gca, 'NextPlot', 'replacechildren');

% disp(fallingDetections)
% disp(falls)
% disp(rises)
% disp("Traj "+i+"  had "+fallingDetections+" falling detections and "+risingDetections+" rising detections");

numberOfSwitchingEventsPerTrajectory(i,1) = fallingDetectionsA; %number of falling events
numberOfSwitchingEventsPerTrajectory(i,2) = risingDetectionsA; %Number of rising events
numberOfSwitchingEventsPerTrajectory(i,3) = numberOfSwitchingEventsPerTrajectory(i,1) + numberOfSwitchingEventsPerTrajectory(i,2); %Total # of events  
if nTraj == 1000
    numberOfSwitchingEventsPerTrajectory(nTraj+1,4) = sum(numberOfSwitchingEventsPerTrajectory(1:1000,3))/nTraj;
end

numberOfSwitchingEventsPerTrajectoryBurnedTime(i,1) = fallingDetectionsABurnedTime; %number of falling events
numberOfSwitchingEventsPerTrajectoryBurnedTime(i,2) = risingDetectionsABurnedTime; %Number of rising events
numberOfSwitchingEventsPerTrajectoryBurnedTime(i,3) = numberOfSwitchingEventsPerTrajectoryBurnedTime(i,1) + numberOfSwitchingEventsPerTrajectoryBurnedTime(i,2); %Total # of events  
if nTraj == 1000
    numberOfSwitchingEventsPerTrajectoryBurnedTime(nTraj+1,4) = sum(numberOfSwitchingEventsPerTrajectoryBurnedTime(1:1000,3))/nTraj;
end
% 
% 	results(i) = [
% 		 i, fallingDetections,risingDetections, fallingDetections + risingDetections
% 	];
end
close(mov)

toc;

minimumNumberSwitchingEventsPerTraj = min(numberOfSwitchingEventsPerTrajectory(:,3));
maximumNumberSwitchingEventsPerTraj = max(numberOfSwitchingEventsPerTrajectory(:,3));
avgNumberSwitchingEventsPerTraj = numberOfSwitchingEventsPerTrajectory(nTraj+1, 4);

minimumNumberSwitchingEventsPerTrajBurnedTime = min(numberOfSwitchingEventsPerTrajectoryBurnedTime(:,3));
maximumNumberSwitchingEventsPerTrajBurnedTime = max(numberOfSwitchingEventsPerTrajectoryBurnedTime(:,3));
avgNumberSwitchingEventsPerTrajBurnedTime = numberOfSwitchingEventsPerTrajectoryBurnedTime(nTraj+1, 4);

disp(min(numberOfSwitchingEventsPerTrajectoryBurnedTime(:,3)))
disp(avgNumberSwitchingEventsPerTrajBurnedTime)
disp(max(numberOfSwitchingEventsPerTrajectoryBurnedTime(:,3)))


% save('TwoCompStochSimUnbiasedStart0P1TimeStepVol0P32ExchRate16P5LongTraj.mat',...
%     'minimumNumberSwitchingEventsPerTraj', 'maximumNumberSwitchingEventsPerTraj',...
%     'allFallingEventsB','allRisingEventsB','allFallingEventsA', 'allRisingEventsA',...
%     'avgNumberSwitchingEventsPerTraj','-append')



function result = rollAvg(values, shiftIn) 
    

    l = length(values);

    for i = 2:l
		values(i - 1) = values(i);
    end

	values(l) = shiftIn;
    result = values;

end

