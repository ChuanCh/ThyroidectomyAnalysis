%% This fn is like augmentLogFile; it appends also time-domain metrics (but not physio)
%  derived from resynthesizing the EGG waveforms with amplitude preserved.
%  FonaDyn230AugmentLogFile is for FonaDyn 2.3.0
function [logPlus] = FonaDyn230AugmentLogFile(logFile, delta)
    [data, samplerate] = audioread(logFile, 'native');
    [frames, channels] = size(data);

    % cTime = data(:, 1);
    % cF0 = data(:, 2);
    % cLevel = data(:, 3);
    % cClarity = data(:, 4);
    % cCrest = data(:, 5);
    % cSpecBal = data(:, 6);
    % cCPPs = data(:, 7);
    % cCluster = data(:, 8);
    % cSampEn = data(:, 9);
    % Icontact = data(:, 10);
    % Qdelta   = data(:, 11);
    % Qcontact = data(:, 12);

    % Offset dB track to actual dB
    data(:,3) = data(:,3) + 120.0;
    % Offset cluster # to 1-based
    data(:,8) = data(:,8) + 1;
    
    nharm = (channels-12)/2; % HERE: 12 is the # of tracks before the FDs
    if delta > 0
        for i = 1:nharm-1
            data(:,i+nharm) = (data(:,i+nharm) - data(:,nharm)); % compute delta-levels 
            phidiff = data(:,i+12+nharm) - data(:,12+nharm);
            folddiff = atan2(sin(phidiff),cos(phidiff));  % constrain to [-pi,pi]
            data(:,i+12+nharm) = folddiff;
        end;
        data(:,13) = 0.0;
        %data(:,8+nharm) = data(:,8+nharm+nharm-1) * 0.5; 
    end

    % Replace time-domain metrics with those from the FD data
    for j = 1: size(data,1)
       [~, ts] = synthEGGfromArrays(data(j,13:13+nharm-2), data(j,13+nharm:13+nharm+nharm-2),nharm-1,100,1.05); 
%       timeTemp(j,1) = ts.p2pAmpl;
       data(j,10) = ts.iC;
       data(j,11) = ts.maxDegg;
       data(j,12) = ts.qC;
    end
    
    logPlus = single(data);
end
