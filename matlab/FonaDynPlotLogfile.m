function FonaDynPlotLogfile(pathname, limits, tracks)
% Plotting of _Log.aiff files from FonaDyn v2.1.0
% Customize to your own needs
% <limits> = [start stop]   frame (cycle) numbers in the Log.aiff file
% <tracks> = [1 2 5 8 9]    numbers of the tracks to plot (1..10), in any order
% Create a figure before calling this function. 

% Track no - contents - unit - domain
%(0  time in seconds - not accessible through the arg <tracks>)
% 1  fo - semitones - MIDI - 30..96
% 2  Signal level - dB re full scale - < 0
% 3  Clarity - fraction - <threshold>..1.0 (default threshold = 0.96)
% 4  Crest factor - number - 0 .. 5
% 5  Spectrum Balance -40..0 dB
% 6  Cluster # - integer - 0 to <nClusters-1>
% 7  SampEn - number - 0 .. 10 (depends on nHarmonics for SampEn)
% 8  Icontact = Qcontact * log10(dEGGmax)
% 9  dEGGmax - peak dEGG normalized to 1 for a sine wave - >= 1
% 10  Qcontact - area of normalized EGG pulse - 0...1

[data, samplerate] = audioread(pathname, limits, 'native');
[frames, channels] = size(data);

nTracks = size(tracks, 2);


%figure(1);

% % Version 2.0.4 ========================================
% nharm = (channels-10)/2; 
% firstharm = 11;
% clusterTrack = 5;
% nClusters = max(data(:,clusterTrack+1)) + 1;   
% labelStrings = ['fo (ST) ';'SL(dBFS)'; 'Clarity '; 'Crest   '; 'Cluster#'; 'SampEn  '; 'Icontact'; 'Qdelta  '; 'Qcontact'];
% yLimits = [30 96; -60 -15; 0.96 1.01; 0 5; 0 (nClusters+1); 0 10; 0 1; 0 20; 0 1]; 

% Version 2.0.5 ========================================
nharm = (channels-11)/2;
firstharm = 12;
% This assumes that all clusters are represented in the log file excerpt
clusterTrack = 7;
nClusters = max(data(:,clusterTrack+1)) + 1;   
labelStrings = ['fo (ST) ';'SL(dBFS)'; 'Clarity '; 'Crest   '; 'SpecBal '; 'Cluster#'; 'SampEn  '; 'Icontact'; 'Qdelta  '; 'Qcontact'];
yLimits = [30 96; -60 -15; 0.96 1.01; 0 5; -40 0; 0 (nClusters+1); 0 10; 0 1; 0 20; 0 1]; 

axisLabels = cellstr(labelStrings);

fdmap = colormapFD(nClusters, 0.7);

for j = 1:nTracks
    i = tracks(j);
    ax(j) = subplot(nTracks,1,j);
    if (i==clusterTrack)  % special treatment for the cluster# track
        hold on
        for c = 1 : nClusters
           clr = fdmap(c,:); 
           jx = find(data(:,clusterTrack+1)==(c-1));
           plot (data(jx,1), data(jx,clusterTrack+1)+1,'.', 'MarkerSize', 8, 'Color', clr);
           axis ij
        end
        hold off
    else
        plot (data(:,1),data(:,i+1),'.', 'MarkerSize', 4);
    end
    ylabel(ax(j), axisLabels{i}, 'FontSize', 8);
    ylim(ax(j), yLimits(i,:));
    grid on
    grid minor
end;

xlabel ('time (s)');

ix = find(tracks == clusterTrack);
if ix > 0
 colormap(ax(ix), fdmap); 
end

linkaxes(ax, 'x');

% Plot the levels and phases for the first 4 harmonics in a separate figure
figure(2);

% nharm == # of harmonics + 1
% The last "harmonic" holds the power level of residual higher harmonics, 
% and a copy of the phase of the fundamental. 

for i = firstharm : firstharm+4
    subplot(2,1,1)
    plot (data(:,1), data(:,i).*10, '.', 'MarkerSize', 2);
    %title('First 4 levels');
    ylabel('Level (dB down)');
    grid on
    grid minor
    hold on
    subplot(2,1,2)
    %plot (unwrap(data(:,1), data(:,i+nharm)));
    plot (data(:,1), data(:,i+nharm), '.', 'MarkerSize', 2);
    %title('First 4 phases');
    xlabel('time (s)');
    ylabel('phase (rad)');
    ylim([-pi, pi]);
    grid on
    grid minor
    hold on
end;

subplot(2,1,1)
legend('FD1','FD2','FD3','FD4');
end

