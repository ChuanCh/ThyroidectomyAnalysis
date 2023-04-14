%% Main script for running the KinderEGG analyses
%  SECTION 1: Set up the selection of files.
%  This section must always be run before any of the others.
%  It sets up variables that are specific to this whole experiment.

% editdir = 'L:/fonadyn/KinderEGG/adults-edited';
% editdir = 'L:/fonadyn/KinderEGG/children-edited';
trimdirA  = 'L:/fonadyn/KinderEGG/adults-trimmed';
trimdirC  = 'L:/fonadyn/KinderEGG/children-trimmed';
finaldirA = 'L:/fonadyn/KinderEGG/adults-final';
finaldirC = 'L:/fonadyn/KinderEGG/children-final';
slicesdirA = 'L:/fonadyn/KinderEGG/adults-slices';
slicesdirC = 'L:/fonadyn/KinderEGG/children-slices';
tempdir = 'L:/fonadyn/KinderEGG/temp';
categs = {'M', 'F', 'G', 'B'};
conds = {'-3SR', '-full'};
formatSpec = '%02d';
nHarmonics = 10;
nClusters = 5;
rangesVRP = [30 90 40 120;         % For Full VRP
            30 90 40 120;
            30 90 40 120;
            30 90 40 120];
rangesSRP = [35 65 50 100;        % For male SRP
             40 70 40 90;         % For female SRP
             45 75 40 90;         % For boy SRP
             45 75 40 90];        % For girl SRP

% In some SRP files we need to skip the initial tones (not speech)
startTimes = zeros(4,14);

% BOYS
startTimes (3, 1) = 8.0;
startTimes (3, 2) = 13.85;
startTimes (3, 3) = 14.5;
startTimes (3, 4) = 11.83;
startTimes (3, 5) = 9.0;
startTimes (3, 6) = 4.1;
startTimes (3, 7) = 0.0;
startTimes (3, 8) = 4.31;
startTimes (3, 9) = 13.2;

% GIRLS
startTimes (4, 4) = 7.5;
startTimes (4, 5) = 21.2;
startTimes (4, 6) = 30.7;
startTimes (4, 7) = 10.65;
startTimes (4, 9) = 10.0;
startTimes (4, 10) = 24.0;
startTimes (4, 11) = 13.8;
startTimes (4, 12) = 7.6;
startTimes (4, 13) = 2.2 ;

subjectNumbers = [1 1 2 1; 13 13 14 9];

includeSubjects = {[1:13], [1:13], [2 3 4 5 6 7 9 10 11 13 14], [1:9]};

% Names of the columns in the array pArr (v2.0.7)
columnLabels = { 'time (s)', '\it f\rm_o (ST)', 'SPL (dB)', 'Clarity', 'Crest (dB)', 'SpecBal (dB)', 'Cluster #', 'SampEn', 'Icontact', 'dEGGmax', 'Qcontact', ...
                 'L_1',  '{\delta}L_2',  '{\delta}L_3',  '{\delta}L_4',  'L_5',  'L_6',  'L_7',  'L_8',  'L_9',  'L_10',   'L_H', ...
               'phi_1','phi_2','phi_3','phi_4','phi_5','phi_6','phi_7','phi_8','phi_9','phi_10','2phi_1' };
           
%% SECTION A: Extract labelled portions and concatenate them into shorter files
% Run the initial setup section first!

% for p = 10:10
%     sub = [categs{4} num2str(p, formatSpec)];
%     subjdir = fullfile(editdir, sub);
%     outdir  = fullfile(trimdir, sub);
%     % mkdir(trimdir, sub);
%     CropFonaDynFilesToCSVlabels(subjdir, outdir)
% end
% 

%% SECTION AA - EXTRACT GAMMA-REGIONS TO .MAT FILES
% %  This is a partly manual procedure, 
% %  so the result needs to be saved as intermediate
% %  in <subject>_gamma_VRP.csv
%
% cond = '-3SR';  
% condOptions = '_fine';
% cat = 1;
% 
% for cat = 1:4
% 
% if cat < 3
%     trimdir = finaldirA;
% else
%     trimdir = finaldirC;
% end
% 
%     for person = includeSubjects{cat}
%         subject = [categs{cat} num2str(person, formatSpec)];
%         workdir = fullfile(trimdir, subject);
%         vrpfilename = [subject cond condOptions '_VRP.csv'];    
%         vrppathname = fullfile(workdir, vrpfilename); 
%         [names, vv] = FonaDynLoadVRP(vrppathname);
% 
%         v = [];
%         topPercent = 50;
%         v = skimVRP(vv,names,topPercent,1);  % manual clicking happens here
%         csvFileName = [subject '_gamma_VRP.csv']
%         csvFilePath = fullfile(workdir, csvFileName);
%         FonaDynSaveVRP(csvFilePath, names, v);  % save the gamma region as a _VRP.csv
% 
%         % Load the SRP log file data for this subject
%         searchFileStr = fullfile(workdir, ['*_' subject '_SRP?_C_Log.aiff']);
%         logfilenames = ls (searchFileStr);
%         logdata = [];
%         for lf = 1 : size(logfilenames,1)
%            fName = fullfile(workdir, logfilenames(lf,:)); 
%            %md = augment4LogFile(fName,0);
%            md = augment8LogFile(fName,0);   % With new speed quotient 
%            logdata = [logdata; md];
%         end
%         startIx = find(logdata(:,1) > startTimes(cat, person), 1);
% 
%         gammaData = pruneLogDataForMat(logdata(startIx:end,:), v);
%         matFileName = [subject '_gamma.mat']
%         matFilePath = fullfile(workdir, matFileName);
%         save(matFilePath, 'gammaData');
%     end
% end

%% SECTION AA2 - EXTRACT VRP data from SRP GAMMA-REGIONS

cond = '-full';  
condOptions = '_fine';

for cat = 1:4
    if cat < 3
        trimdir = finaldirA;
        finaldir = finaldirA;
    else
        trimdir = finaldirC;
        finaldir = finaldirC;
    end

    for person = includeSubjects{cat} 
        subject = [categs{cat} num2str(person, formatSpec)];
        workdir = fullfile(trimdir, subject);
        vrpfilename = [subject cond condOptions '_VRP.csv'];    
        vrppathname = fullfile(workdir, vrpfilename); 
        [names, vv] = FonaDynLoadVRP(vrppathname);

        csvFileName = [subject '_gamma_VRP.csv']
        csvFilePath = fullfile(workdir, csvFileName);
        [names, ss] = FonaDynLoadVRP(csvFilePath);
        v = cropVRP(ss,vv); 
        csvFileName = [subject '_gamma2_VRP.csv']
        csvFilePath = fullfile(workdir, csvFileName);
        FonaDynSaveVRP(csvFilePath, names, v);  % save the gamma2 region as a _VRP.csv

        % Load the VRP log file data for this subject
        searchFileStr = fullfile(workdir, ['*_' subject '_VRP?_C_Log.aiff']);
        logfilenames = ls (searchFileStr);
        logdata = [];
        for lf = 1 : size(logfilenames,1)
           fName = fullfile(workdir, logfilenames(lf,:)); 
           %md = augment4LogFile(fName,0);
           md = augment8LogFile(fName,0);   % With new speed quotient 
           logdata = [logdata; md];
        end

        gammaData = pruneLogDataForMat(logdata, v);
        matFileName = [subject '_gamma2.mat']
        matFilePath = fullfile(workdir, matFileName);
        save(matFilePath, 'gammaData');
    end
end

%% SECTION AA3 - EXTRACT voice map data from existing GAMMA-REGIONS

cond = '_SRP';  
condOptions = '-3SR_fine';

for cat = 1:1
    if cat < 3
%        trimdir = trimdirA;
        finaldir = finaldirA;
    else
%        trimdir = trimdirC;
        finaldir = finaldirC;
    end

    for person = 4:4 % subjectNumbers(1, cat) : subjectNumbers(2, cat)
        subject = [categs{cat} num2str(person, formatSpec)];
        workdir = fullfile(finaldir, subject);
        vrpfilename = [subject condOptions '_VRP.csv'];    
        vrppathname = fullfile(workdir, vrpfilename); 
        [names, vv] = FonaDynLoadVRP(vrppathname);

        csvFileName = [subject '_gamma2_VRP.csv']
        csvFilePath = fullfile(workdir, csvFileName);
        [~, ss] = FonaDynLoadVRP(csvFilePath);
        v = cropVRP(ss,vv); 
        csvFileName = [subject condOptions '_gamma_VRP.csv']
        csvFilePath = fullfile(workdir, csvFileName);
        FonaDynSaveVRP(csvFilePath, names, v);  % save the map constrained to gamma

        % Load the S/VRP log files data for this subject
        searchFileStr = fullfile(workdir, ['*_' subject cond '?_C_Log.aiff']);
        logfilenames = ls (searchFileStr);
        logdata = [];
        for lf = 1 : size(logfilenames,1)
           fName = fullfile(workdir, logfilenames(lf,:)); 
           %md = augment4LogFile(fName,0);
           md = augment8LogFile(fName,0);   % With new speed quotient 
           logdata = [logdata; md];
        end

        gammaData = pruneLogDataForMat(logdata, v);
        matFileName = [subject cond '_gamma2.mat'];
        matFilePath = fullfile(workdir, matFileName)
        save(matFilePath, 'gammaData');
    end
end
%% SECTION AA4 - Concatenate all GAMMA-REGION vrps for SPSS

cond = '_VRP';  
condOptions = '-full_gamma2';
statMode = '_std';
% meancellcount = 23.76; % average SRP gamma area, from New-gamma-statistics.xlsx
meancellcount = 22.35; % ditto VRP


tArray = zeros(1,16);
pNum = 1;

for cat = 1:4
    if cat < 3
%        trimdir = trimdirA;
        finaldir = finaldirA;
    else
%        trimdir = trimdirC;
        finaldir = finaldirC;
    end

    for person = includeSubjects{cat}
        subject = [categs{cat} num2str(person, formatSpec)];
        workdir = fullfile(finaldir, subject);

        csvFileName = [subject condOptions statMode '_VRP.csv']
        csvFilePath = fullfile(workdir, csvFileName);
        [names, ss] = FonaDynLoadVRP(csvFilePath);
        cellcount = size(ss,1);

        % compute the inverse weight of the cell count per person
        wc = meancellcount/cellcount;
        wcCol = repmat(wc, cellcount, 1);

        % compute the weights of cycle counts within the person
        meancycles = mean(ss(:,3));
        wtCol = [];
        for c = 1 : cellcount
            wtCol(c) = ss(c,3)/meancycles; 
        end
        
        % compute the combined weight of cycle counts and cell counts
        wCol = wtCol * wc;

        group = min(cat, 3);  % combine G and B
        gCol = repmat(group, cellcount,1);
        pCol = repmat(pNum, cellcount,1);
        pArray = [gCol pCol wcCol wtCol' wCol' ss(:,1:11)]; 
        tArray = [tArray; pArray];
        pNum = pNum+1;
    end
 
    colNames = {'Group' 'Person' 'wCell' 'wCycles' 'wProd' names{1:11}};
       
    T = array2table(tArray(2:end,:), 'VariableNames', colNames);
    tableFileName = fullfile(tempdir, ['Stats5' cond '-cells' statMode '.csv']);
    writetable(T, tableFileName, 'Delimiter', ';');
end
%% SECTION AA5:  Make new _VRP files from gamma-region .mat files, 
% selecting mean (the usual), std, median or spread,
% with Ic, Qci, Qdelta and Qsi computed from the FDs instead of the time signal

cond = '_VRP';  
condOptions = '-full_gamma2';  % with tweaked SampEn, and SpecBal, and Qspeed inserted
statModes = { '_mean', '_std', '_median', '_spread' };

% cond = '_VRP';  
%csvFix = '-full_FD4_VRP.csv';  % with Gibbs

statMode = 2;  % means:1 std:2 median:3 spread:4

for cat = 1 : 4

    if cat < 3
        trimdir = trimdirA;
        finaldir = finaldirA;
    else
        trimdir = trimdirC;
        finaldir = finaldirC;
    end

    for person = includeSubjects{cat}
        subject = [categs{cat} num2str(person, formatSpec)];
        workdir = fullfile(finaldir, subject);  % finaldir is where the latest log files are
        matfilename = fullfile(workdir, [ subject '_gamma2.mat']);
        load (matfilename);

        [names, p1, v1] = FonaDynArraysLogFileStatsToVRP(gammaData, nClusters, statMode); %Assumes Qspeed included
        [b, ix] = sort(v1(:,3), 'descend');
        vSorted = v1(ix,:);
        csvFileName = [subject condOptions statModes{statMode} '_VRP.csv'];
        csvFilePath = fullfile(finaldir, subject, csvFileName)
        FonaDynSaveVRP(csvFilePath, names, vSorted);
    end
end

%% SECTION AB - COMPUTE STATS OF GAMMA-REGION PROPERTIES

cond = '_SRP';  
condOptions = '_gamma2';  % gamma for SRP gamma regions, gamma2 for VRP gamma regions

fStr = ['New5-gamma2-statistics.csv'];
statsfile = fullfile(tempdir, fStr);
fStats = fopen(statsfile, 'w');
header = 'Subject;fo.mean Hz;fo.range ST;L.mean dB;L.range dB;Area;totCyc;minCyc;maxCyc';
fprintf(fStats, '%s\r\n', header);

for cat = 1:4

if cat < 3
%    trimdir = trimdirA;
    finaldir = finaldirA;
else
%    trimdir = trimdirC;
    finaldir = finaldirC;
end

    for person = includeSubjects{cat} 
        subject = [categs{cat} num2str(person, formatSpec)];
        workdir = fullfile(finaldir, subject);
        csvFileName = [subject condOptions '_VRP.csv']
        csvFilePath = fullfile(workdir, csvFileName);
        [names, vrpArray] = FonaDynLoadVRP(csvFilePath);  % load the gamma region 

        area = size(vrpArray, 1);
        totalCycles = sum(vrpArray(:,3));
        minCycles = min(vrpArray(:,3));
        maxCycles = max(vrpArray(:,3));
 
        %compute the weighted MIDI mean
        meanMidi = sum(vrpArray(:,1) .* vrpArray(:,3))/totalCycles;
        meanHz = 220*2^((meanMidi-57)/12);

        %compute the MIDI range
        foRange = max(vrpArray(:,1)) - min(vrpArray(:,1)) + 1;
        
        %compute the weighted Level mean
        meanLevel = sum(vrpArray(:,2) .* vrpArray(:,3))/totalCycles;

        %compute the Level range
        splRange = max(vrpArray(:,2)) - min(vrpArray(:,2)) + 1;

        fprintf(fStats, "%s;%.1f;%.2f;%.1f;%.2f;%d;%d;%d;%d\r\n", ... 
            subject, meanHz, foRange, meanLevel, splRange, area, totalCycles, minCycles, maxCycles);
    end
end
fclose(fStats);


%% SECTION A1: Plot per-metric VRPs as in FonaDyn
%  with optional gamma regions from the SRPs

bGamma = 1;

cat = 1;
if cat < 3
    trimdir = trimdirA;
else
    trimdir = trimdirC;
end

for person = includeSubjects{cat}
    subject = [categs{cat} num2str(person, formatSpec)];
    outdir  = fullfile(trimdir, subject);
    cond = '-full';  % cluster file is always '_before'
    condOptions = '_FD2';
    clusterfilename = [subject cond '_clusters.csv'];
    workdir = fullfile(trimdir, subject);
    clusterpathname = fullfile(workdir, clusterfilename); 
    printpathname = fullfile(tempdir, [subject cond condOptions '.pdf']);

    threshold = 5; % min cycles required for plot

    f = figure('Units', 'normalized','Color', 'white','Position', [0.1, 0.1, 0.6, 0.6], ...
        'PaperPosition', [1, 0, 27, 19]);

    vrpfig = figure(f);
    grid on 
    range = rangesVRP(cat,:);
    box on 

    tStr = sprintf('SPL @0.3m(dB) Min %i cycles', threshold);
    %metrics = {'Qcontact', 'dEGGmax', 'Crest'};
    metrics = {'dEGGmax', 'Qcontact', 'Qspeed'; ...
               'Total', 'maxCluster', 'Total'};

    vrpfilename = [subject cond condOptions '_VRP.csv'];
    vrppathname = fullfile(workdir, vrpfilename); 
    [n, vv] = FonaDynLoadVRP(vrppathname);
    
    regfilename = [subject '_gamma_VRP.csv'];    
    regpathname = fullfile(workdir, regfilename); 
    [nn, v] = FonaDynLoadVRP(regpathname);;
%     if bGamma > 0
%         topPercent = 50;
%         srpfilename = [subject '-3SR_FD2_VRP.csv'];
%         srppathname = fullfile(workdir, srpfilename); 
%         [n, ss] = FonaDynLoadVRP(srppathname);
%         s = skimVRP(ss,n,topPercent);  % get the gamma region from the SRP
%         v = cropVRP(s, vv);            % copy only that region from the VRP
%     end
    
    h = size(metrics, 1);
    w = size(metrics, 2);
    for c = 1 : h
        for m = 1 : w
            metric = metrics{c,m};
            left = m*0.25 + 0.02;
            p = m + w*(c-1);
            ax = subplot(h,w,p);  %, 'position', [left 0.12 0.22 0.8]);
            if p < 6
                pbaspect(ax, [2 1 1]);
                FonaDynPlotVRP(vv, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, ...
                    'Range', range, 'PlotHz', 'on', 'Mesh', 'off', 'Special', 1, 'Region', v);
                box on; grid on; 
                title ([subject cond], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
                %xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
                xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
                if m==1
                    ylabel (tStr, 'FontSize', 8);
                end
            else
                pbaspect(ax, [1 1 1]);
                [egg, Qci, Qsi, maxDegg, Ic, ampl] = synthEGGfromFile(clusterpathname, 100, 2);
                plotEGG(egg, clusterfilename, ax);
                N = length(Qci);
                colors = colormapFD(N, 0.7);
                for i = 1 : N
                    sD = 0.015;  % shadow offset
                    color = colors(i, :)*0.6;
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), Qci(i));
                    text(3+sD, 4.9-i-sD, lStr{i}, 'FontSize', 8);
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
                    text(100+sD, 5.1-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}?%0.3g ',  color(1), color(2), color(3), Qsi(i));
                    text(160+sD, 5.3-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'left');

                    color = colors(i, :);
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), Qci(i));
                    text(3, 4.9-i, lStr{i}, 'FontSize', 8);
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
                    text(100, 5.1-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}?%0.3g ',  color(1), color(2), color(3), Qsi(i));
                    text(160, 5.3-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'left');

                end
                %legend(lStr, 'Location', 'northwest', 'Box', 'off'); 
                xlabel('EGG cycle time (%)', 'FontSize', 8);
                % ylabel ('Cluster # with Q_{ci} and /dEGG_{maxN}', 'FontSize', 10);
%                 ylabel ('Cluster # with Q_{ci}  /Q_{\Delta}  Q_{si}', 'FontSize', 10);
                title ('Q_{ci}              /Q_{\Delta}                ?Q_{si}', 'FontSize', 10, 'Interpreter', 'tex');
                ylabel ('Cluster #', 'FontSize', 10);
                ylim ([-0.6 4.6])
            end
            drawnow
         end
    end
  f.PaperOrientation = 'landscape';
  print('-painters','-dpdf', printpathname);
  close(f);
end

%% SECTION A2: Plot 1..4 per-metric SRPs 
%  with optional gamma region and statistics log
bGamma = 1;

cat = 1;
cond = '-3SR';  
range = rangesSRP(cat, :);
condOptions = '_fine';

if cat < 3
    trimdir = trimdirA;
    finaldir = finaldirA;
else
    trimdir = trimdirC;
    finaldir = finaldirC;
end

if bGamma > 2
    fStr = [categs{cat} cond condOptions '-gamma-statistics.csv'];
    statsfile = fullfile(tempdir, fStr);
    fStats = fopen(statsfile, 'a');
    header = 'Subject;fo.mean Hz;fo.std ST;L.mean dB;L.std dB;Qci.mean;Qci/ST;Qci/dB;Qsi.mean;Qsi/ST;Qsi/dB;Qd.mean;Qd/ST;Qd/dB;Ic.mean;Ic/ST;Ic/dB;Crest.mean;Crest/ST;Crest/dB;TotCycles;TotCells';
    fprintf(fStats, '%s\r\n', header);
end

for person = 1:1 % includeSubjects{cat}
    subject = [categs{cat} num2str(person, formatSpec)];
    outdir  = fullfile(tempdir, subject);
    clusterfilename = [subject cond '_clusters.csv'];
    workdir = fullfile(trimdir, subject);
    clusterpathname = fullfile(workdir, clusterfilename); 
    printpathname = fullfile(tempdir, [subject cond condOptions '.pdf']);

    threshold = 5; % min cycles required for plot

    f = figure('Units', 'normalized','Color', 'white','Position', [0.1, 0.05, 0.6, 0.6], ...
        'PaperPosition', [1, 0, 27, 19]);

    vrpfig = figure(f);
    grid on 
    box on 

    tStr = sprintf('SPL @0.3m(dB) Min %i cycles', threshold);
    metrics = { 'Qcontact', 'dEGGmax', 'Qspeed'; ...
                'Entropy', 'maxCluster', 'Total' };%Cluster 1,Cluster 2
%     metrics = {'dEGGmax', ; ...
%                'Qcontact', ; ...
%                'Qspeed',   'Total' ; ...
%                'Total'};
    
    vrpfilename = [subject cond condOptions '_VRP.csv'];    
    vrppathname = fullfile(finaldir, subject, vrpfilename); 
    [n, vv] = FonaDynLoadVRP(vrppathname);

    regfilename = [subject '_gamma_VRP.csv'];    
    regpathname = fullfile(finaldir, subject, regfilename); 
    [nn, v] = FonaDynLoadVRP(regpathname);
    
    if bGamma > 1
    logStats(['t_' subject],vv,n,fStats, threshold);
    fprintf(fStats, '\r\n');
        topPercent = 50;
    uv = skimVRP(vv,n,topPercent, 0);
    logStats(['u_' subject],uv,n,fStats, 1);
    fprintf(fStats, '\r\n');
        logStats([subject],v,n,fStats, 1);
    end

    h = size(metrics, 1);
    w = size(metrics, 2);

    for c = 1 : h
        for m = 1 : w
            metric = metrics{c,m};
            left = m*0.25 + 0.02;
            p = m + w*(c-1);
            ax = subplot(h,w,p);  %, 'position', [left 0.12 0.22 0.8]);
            % ax = subplot(1,1,p);  %, 'position', [left 0.12 0.22 0.8]);
            if (p < 6) 
                pbaspect(ax, [2 1 1]);
                FonaDynPlotVRP(vv, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, ... 
                    'Range', range, 'PlotHz', 'on', 'Special', 0, 'Region', v);
                box on; grid on;
                title ([subject cond], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
                %xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
                xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
                if m==1
                    ylabel (tStr, 'FontSize', 8);
                end
            else
%                ax = subplot(h,w, p); 
                [egg, Qci, Qsi, maxDegg, Ic, ampl] = synthEGGfromFile(clusterpathname, 100, 4);
                plotEGG(egg, clusterfilename, ax);
                N = length(Qci);
                colors = colormapFD(N, 0.7);
                for i = 1 : N
                    sD = 0.015;  % shadow offset
                    color = colors(i, :)*0.6;
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), Qci(i));
                    text(3+sD, 4.9-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'left');
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
                    text(200+sD, 5.1-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}?%0.3g ',  color(1), color(2), color(3), Qsi(i));
                    text(300+sD, 5.3-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');

                    color = colors(i, :);
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), Qci(i));
                    text(3, 4.9-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'left');
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
                    text(200, 5.1-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}?%0.3g ',  color(1), color(2), color(3), Qsi(i));
                    text(300, 5.3-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');

                end
                %legend(lStr, 'Location', 'northwest', 'Box', 'off'); 
                xlabel('EGG cycle time (%)', 'FontSize', 8);
                % ylabel ('Cluster # with Q_{ci} and /dEGG_{maxN}', 'FontSize', 10);
                title ('Q_{ci}               /Q_{\Delta}              ?Q_{si}', 'FontSize', 10, 'Interpreter', 'tex');
                ylabel ('Cluster #', 'FontSize', 10);
                ylim ([-0.6 4.6])
            end
            drawnow
         end
    end
%     f.PaperOrientation = 'landscape';
%     print('-painters','-dpdf', printpathname);
%     close(f);
    if bGamma > 2
         fprintf(fStats, '\r\n');
    end
end
if bGamma > 2
    fclose(fStats);
end

%% SECTION A3: Plot 1..4 per-metric VRPs 
%  with optional stats under gamma region from SRPs

cat = 1; 
cond = '-full';
condOptions = '_fine';
threshold = 5; % min cycles required for plot
bGamma = 1;

if cat < 3
    trimdir = trimdirA;
    finaldir = finaldirA;
else
    trimdir = trimdirC;
    finaldir = finaldirC;
end

if bGamma > 2
    fStr = [categs{cat} cond condOptions '-statistics.csv'];
    statsfile = fullfile(tempdir, fStr);
    fStats = fopen(statsfile, 'w');
    header = 'Subject;fo.mean Hz;fo.std ST;L.mean dB;L.std dB;Qci.mean;Qci/ST;Qci/dB;Qsi.mean;Qsi/ST;Qsi/dB;Qd.mean;Qd/ST;Qd/dB;Ic.mean;Ic/ST;Ic/dB;Crest.mean;Crest/ST;Crest/dB';
    fprintf(fStats, '%s\r\n', header);
end

for person = 7:7 % includeSubjects{cat}
    subject = [categs{cat} num2str(person, formatSpec)];
    outdir  = fullfile(trimdir, subject);
    cond = '-full';  
    clusterfilename = [subject cond '_clusters.csv'];
    workdir = fullfile(trimdir, subject);
    clusterpathname = fullfile(workdir, clusterfilename); 
    printpathname = fullfile(tempdir, [subject cond condOptions '_VRP.pdf']);

    f = figure('Units', 'normalized','Color', 'white','Position', [0.1, 0.05, 0.6, 0.6], ...
        'PaperPosition', [1, 0, 27, 19]);

    vrpfig = figure(f);
    grid on 
    range = rangesVRP(cat,:);
    box on 

    tStr = sprintf('SPL @0.3m(dB) Min %i cycles', threshold);
    %metrics = {'Qcontact', 'dEGGmax', 'Crest'};
    %metrics = {'Total', 'Entropy', 'Crest'; 'Qcontact', 'dEGGmax', 'Qspeed'; 'Icontact', 'maxCluster', 'eggShapes'};
    metrics = { 'Qcontact', 'dEGGmax', 'Qspeed'; ...
                'Entropy', 'maxCluster', 'Total' };

    vrpfilename = [subject cond condOptions '_VRP.csv'];
    vrppathname = fullfile(finaldir, subject, vrpfilename); 
    [n, vv] = FonaDynLoadVRP(vrppathname);

    regfilename = [subject '_gamma_VRP.csv'];    % Use the gamma from the -3SR
    regpathname = fullfile(finaldir, subject, regfilename); 
    [nn, v] = FonaDynLoadVRP(regpathname);

%     if bGamma > 2
%         topPercent = 50;
%         srpfilename = [subject '-3SR_FD3_VRP.csv'];
%         srppathname = fullfile(workdir, srpfilename); 
%         [n, ss] = FonaDynLoadVRP(srppathname);
%         s = skimVRP(ss,n,topPercent);  % get the gamma region from the SRP
%         v = cropVRP(s, vv);            % copy only that region from the VRP
%         logStats(subject,v,n,fStats);
%     end
    
    h = size(metrics, 1);
    w = size(metrics, 2);

    for c = 1 : h
        for m = 1 : w
            metric = metrics{c,m};
            left = m*0.25 + 0.02;
            p = m + w*(c-1);
            ax = subplot(h,w,p);  %, 'position', [left 0.12 0.22 0.8]);
            if p < 6
                pbaspect(ax, [2 1 1]);
                FonaDynPlotVRP(vv, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, ... 
                    'Range', range, 'PlotHz', 'on', 'Mesh', 'on', 'Special', 0, 'Region', v);
                box on; grid on;
                title ([subject cond], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
                %xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
                xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
                if m==1
                    ylabel (tStr, 'FontSize', 8);
                end
            else
                pbaspect(ax, [1.1 1.25 1]);
                [egg, Qc, Qsi, maxDegg, Ic, ampl] = synthEGGfromFile(clusterpathname, 100, 4);
                plotEGG(egg, clusterfilename, ax);
                N = length(Qc);
                colors = colormapFD(N, 0.7);
                for i = 1 : N
                    sD = 0.015;  % shadow offset
                    color = colors(i, :)*0.6;
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), Qc(i));
                    text(3+sD, 4.9-i-sD, lStr{i}, 'FontSize', 8);
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
                    text(200+sD, 5.1-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}?%0.3g ',  color(1), color(2), color(3), Qsi(i));
                    text(300+sD, 5.3-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');

                    color = colors(i, :);
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), Qc(i));
                    text(3, 4.9-i, lStr{i}, 'FontSize', 8);
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
                    text(200, 5.1-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}?%0.3g ',  color(1), color(2), color(3), Qsi(i));
                    text(300, 5.3-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
                end
%                 %legend(lStr, 'Location', 'northwest', 'Box', 'off'); 
%                 xlabel('EGG cycle time (%)', 'FontSize', 8);
%                 ylabel ('Cluster # with Q_{ci} /Q_{\Delta} ?Q_{si}', 'FontSize', 10);
%                 ylim ([-0.6 4.6]);
                xlabel('EGG cycle time (%)', 'FontSize', 8);
                % ylabel ('Cluster # with Q_{ci} and /dEGG_{maxN}', 'FontSize', 10);
                title ('Q_{ci}               /Q_{\Delta}              ?Q_{si}', 'FontSize', 10, 'Interpreter', 'tex');
                ylabel ('Cluster #', 'FontSize', 10);
                ylim ([-0.6 4.6])
            end
            drawnow
         end
    end
%    f.PaperOrientation = 'landscape';
%    print('-painters','-dpdf', printpathname);
%    close(f);
%    fprintf(fStats, '\r\n');
end
%fclose(fStats);

%% SECTION A4: Plot 1..4 per-metric VRPs with means in top row and SDs in the bottom row 
% from skimmed SRPs

category = 1; 

for person = 1:13
    subject = [categs{category} num2str(person, formatSpec)];
    outdir  = fullfile(trimdir, subject);
    cond = '-full';  
    clusterfilename = [subject cond '_clusters.csv'];
    workdir = fullfile(trimdir, subject);
    clusterpathname = fullfile(workdir, clusterfilename); 
    printpathname = fullfile(trimdir, [subject cond '-FDS.pdf']);

    threshold = 5; % min cycles required for plot

    f = figure('Units', 'normalized','Color', 'white','Position', [0.1, 0.1, 0.6, 0.5]);

    vrpfig = figure(f);
    grid on 
    range = rangesVRP(category,:);
    box on 

    tStr = sprintf('SPL @ 0.3 m (dB) Threshold: %i cycles', threshold);
    %metrics = {'Qcontact', 'dEGGmax', 'Crest'};
    %metrics = {'Qcontact', 'dEGGmax', 'Icontact', 'Crest'};
    metrics = {'Qcontact', 'dEGGmax', 'Icontact', 'Crest'};
    mScales = [0.1, 3, 0.1, 1];

    vrpfilename = [subject cond '_FD_VRP.csv'];
    vrppathname = fullfile(workdir, vrpfilename); 
    [n, vv] = FonaDynLoadVRP(vrppathname);

    topPercent = 50;
    srpfilename = [subject '-3SR_FD_VRP.csv'];
    srppathname = fullfile(workdir, srpfilename); 
    [n, ss] = FonaDynLoadVRP(srppathname);
    s = skimVRP(ss,n,topPercent);  % get the gamma region from the SRP
    v = cropVRP(s, vv);            % copy only that region from the VRP
%    logStats(subject,v,n,fStats);

    w = size(metrics, 2);

    % Subplots in the top row
    for m = 1 : w
        metric = metrics{m};
        left = m*0.25 + 0.02;
        p = m ;
        ax = subplot(2,w,p);  %, 'position', [left 0.12 0.22 0.8]);
        pbaspect(ax, [2 1 1]);
        FonaDynPlotVRP(vv, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, ... 
            'Range', range, 'PlotHz', 'off', 'Region', s);
        box on; grid on;
        title ([subject cond], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
        xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
        %xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
        if m==1
            ylabel (tStr, 'FontSize', 8);
        end
        drawnow
    end
     
    % Subplots in the bottom row
    vrpfilename = [subject cond '_FDstd_VRP.csv'];
    vrppathname = fullfile(workdir, vrpfilename); 
    [n, vv] = FonaDynLoadVRP(vrppathname);

    for m = 1 : w
        metric = metrics{m};
        left = m*0.25 + 0.02;
        p = m + w;
        ax = subplot(2,w,p);  %, 'position', [left 0.12 0.22 0.8]);
        pbaspect(ax, [2 1 1]);
        FonaDynPlotVRP(vv, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, ... 
            'Range', range, 'PlotHz', 'on', 'Region', s, 'SDscale', mScales(m));
        box on; grid on;
        title ([subject cond], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
        %xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
        xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
        if m==1
            ylabel (tStr, 'FontSize', 8);
        end
        drawnow
    end
        
    f.PaperOrientation = 'landscape';
    f.PaperUnits = 'normalized';
    f.PaperPosition = [0.0 0.15 1 0.7];
    print('-painters','-dpdf', printpathname);
    close(f);
end

%% SECTION A5: Plot demo figure for MAVEBA article 

for person = 3:3
    subject = [categs{1} num2str(person, formatSpec)];
    outdir  = fullfile(trimdir, subject);
    cond = '-3SR';  % cluster file is always '_before'
    clusterfilename = [subject cond '_clusters.csv'];
    workdir = fullfile(trimdir, subject);
    clusterpathname = fullfile(workdir, clusterfilename); 
    printpathname = fullfile(trimdir, [subject cond '-modes.pdf']);

    threshold = 5; % min cycles required for plot

    f = figure('Units', 'normalized','Color', 'white','Position', [0.05, 0.05, 0.1, 0.75]);
    colormap(f,'autumn');
    
    vrpfig = figure(f);
    grid on 
    %range = [30 90 40 120];         % For Full VRP
    %range = [35 70 50 100];         % For male SRP
    %range = [35 75 40 110];         % For male SRP
    %range = [45 70 50 90];         % For female SRP
    range = [35 60 60 90];         % For Maveba Fig. 1
    box on 

    tStr = sprintf('SPL @ 0.3 m (dB)  Threshold: %d', threshold);
    %metrics = {'Qcontact', 'dEGGmax', 'Crest'};
    metrics = {'Qcontact'; 'dEGGmax'; 'Icontact'; 'Crest'};

    % cond = char(categs{c}); % '_before' or '_after';
    vrpfilename = [subject '-3SR' '_VRP.csv'];
    vrppathname = fullfile(workdir, vrpfilename); 
    [n, v] = FonaDynLoadVRP(vrppathname);
    vvv = skimVRP(v,n,95);
    vv = skimVRP(v,n,50);

%     vrpfilename = [subject cond '_VRP.csv'];
%     vrppathname = fullfile(workdir, vrpfilename); 
%     [n, v] = FonaDynLoadVRP(vrppathname);
    
%     logStats(subject,v,n,fStats);

    h = size(metrics, 1);
    w = size(metrics, 2);

    for c = 1 : h
        for m = 1 : w
            metric = metrics{c,m};
            left = m*0.25 + 0.02;
            p = m + w*(c-1);
            ax = subplot(h,w,p);  %, 'position', [left 0.12 0.22 0.8]);
            % ax = subplot(h,w,p);  %, 'position', [left 0.12 0.22 0.8]);
            % ax = subplot(1,1,p);  %, 'position', [left 0.12 0.22 0.8]);
            if p < 7
                pbaspect(ax, [2 1 1]);
                if (p == 3) || (p == 4)
                FonaDynPlotVRP(v, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, ... 
                    'Range', range, 'PlotHz', 'off');
                end
                if (p == 1)
                FonaDynPlotVRP(v, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, ...
                    'Range', range, 'PlotHz', 'off', 'Region', vv);
                end
                if (p == 2)
                FonaDynPlotVRP(v, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, ...
                    'Range', range, 'PlotHz', 'off', 'Region', vv);
                end
                box on; grid on;
                title ([subject cond], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
                %xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
                if (c == h)
                    xlabel('\it f\rm_o (MIDI, )', 'FontSize', 8);
                end
                if m==1
                    ylabel (tStr, 'FontSize', 8);
                end
            else
                pbaspect(ax, [1 1.25 1]);
                [egg, Qc, maxDegg, normDegg, ampl, integr] = synthEGGfromFile(clusterpathname, 100, 2);
                plotEGG(egg, clusterfilename, ax);
                N = length(Qc);
                colors = colormapFD(N, 0.7);
                for i = 1 : N
                    sD = 0.015;  % shadow offset
                    color = colors(i, :)*0.6;
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), integr(i));
                    text(3+sD, 4.9-i-sD, lStr{i}, 'FontSize', 8);
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
                    text(100+sD, 5.1-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');

                    color = colors(i, :);
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), integr(i));
                    text(3, 4.9-i, lStr{i}, 'FontSize', 8);
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
                    text(100, 5.1-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
                end
                %legend(lStr, 'Location', 'northwest', 'Box', 'off'); 
                xlabel('EGG cycle time (%)', 'FontSize', 8);
                ylabel ('Cluster # with \it Q\rm_{ci} and /\it Q\rm_{\Delta}', 'FontSize', 10);

            end
            drawnow
         end
    end
end


%% SECTION A6: Plot 1..8 subject VRPs of one metric
%  with optional stats under gamma region from SRPs

cat = 1; 
cond = '-full';
condOptions = '_fine';
threshold = 5; % min cycles required for plot
bGamma = 1;

if cat < 3
    trimdir = trimdirA;
    finaldir = finaldirA;
else
    trimdir = trimdirC;
    finaldir = finaldirC;
end

if bGamma > 2
    fStr = [categs{cat} cond condOptions '-statistics.csv'];
    statsfile = fullfile(tempdir, fStr);
    fStats = fopen(statsfile, 'w');
    header = 'Subject;fo.mean Hz;fo.std ST;L.mean dB;L.std dB;Qci.mean;Qci/ST;Qci/dB;Qsi.mean;Qsi/ST;Qsi/dB;Qd.mean;Qd/ST;Qd/dB;Ic.mean;Ic/ST;Ic/dB;Crest.mean;Crest/ST;Crest/dB';
    fprintf(fStats, '%s\r\n', header);
end

f = figure('Units', 'normalized','Color', 'white','Position', [0.1, 0.05, 0.6, 0.4], ...
    'PaperPosition', [1, 0, 27, 19]);

vrpfig = figure(f);
grid on 
range = rangesVRP(cat,:);
box on 
% persons = includeSubjects{cat};
persons = [ 1 2 4 5 6 7 3 9 10 11 12 13];
nPersons = 12;

% for person = persons(1:nPersons)
    
    h = nPersons / 6;
    w = nPersons / 2;
    p = 1;


    for c = 1 : h
        for m = 1 : w
            metric = metrics{1}; % metrics{c,m};
            left = m*0.25 + 0.02;

            person = persons(p);
            subject = [categs{cat} num2str(person, formatSpec)];
            outdir  = fullfile(trimdir, subject);
            cond = '-full';  
            clusterfilename = [subject cond '_clusters.csv'];
            workdir = fullfile(trimdir, subject);
            clusterpathname = fullfile(workdir, clusterfilename); 
            printpathname = fullfile(tempdir, [subject cond condOptions '_VRP.pdf']);

            tStr = sprintf('SPL @0.3m(dB) Min %i cycles', threshold);
            metrics = {'dEGGmax'};
            %metrics = {'Total', 'Entropy', 'Crest'; 'Qcontact', 'dEGGmax', 'Qspeed'; 'Icontact', 'maxCluster', 'eggShapes'};
            %metrics = { 'Qcontact', 'dEGGmax', 'Qspeed'; ...
            %            'Entropy', 'maxCluster', 'Total' };

            vrpfilename = [subject cond condOptions '_VRP.csv'];
            vrppathname = fullfile(finaldir, subject, vrpfilename); 
            [n, vv] = FonaDynLoadVRP(vrppathname);

            regfilename = [subject '_gamma_VRP.csv'];    % Use the gamma from the -3SR
            regpathname = fullfile(finaldir, subject, regfilename); 
            [nn, v] = FonaDynLoadVRP(regpathname);

%     if bGamma > 2
%         topPercent = 50;
%         srpfilename = [subject '-3SR_FD3_VRP.csv'];
%         srppathname = fullfile(workdir, srpfilename); 
%         [n, ss] = FonaDynLoadVRP(srppathname);
%         s = skimVRP(ss,n,topPercent);  % get the gamma region from the SRP
%         v = cropVRP(s, vv);            % copy only that region from the VRP
%         logStats(subject,v,n,fStats);
%     end
            % p = m + w*(c-1);
            ax = subplot(h,w,p);  %, 'position', [left 0.12 0.22 0.8]);
            if p < 20
                pbaspect(ax, [2 1 1]);
                FonaDynPlotVRP(vv, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, ... 
                    'Range', range, 'PlotHz', 'on', 'Special', 0, 'Region', v);
                box on; grid on;
                title ([subject cond], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
                %xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
                xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
                if m==1
                    ylabel (tStr, 'FontSize', 8);
                end
                p = p + 1; 
%             else
%                 pbaspect(ax, [1.1 1.25 1]);
%                 [egg, Qc, Qsi, maxDegg, Ic, ampl] = synthEGGfromFile(clusterpathname, 100, 4);
%                 plotEGG(egg, clusterfilename, ax);
%                 N = length(Qc);
%                 colors = colormapFD(N, 0.7);
%                 for i = 1 : N
%                     sD = 0.015;  % shadow offset
%                     color = colors(i, :)*0.6;
%                     lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), Qc(i));
%                     text(3+sD, 4.9-i-sD, lStr{i}, 'FontSize', 8);
%                     lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
%                     text(200+sD, 5.1-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
%                     lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}?%0.3g ',  color(1), color(2), color(3), Qsi(i));
%                     text(300+sD, 5.3-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
% 
%                     color = colors(i, :);
%                     lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), Qc(i));
%                     text(3, 4.9-i, lStr{i}, 'FontSize', 8);
%                     lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
%                     text(200, 5.1-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
%                     lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}?%0.3g ',  color(1), color(2), color(3), Qsi(i));
%                     text(300, 5.3-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
%                 end
% %                 %legend(lStr, 'Location', 'northwest', 'Box', 'off'); 
% %                 xlabel('EGG cycle time (%)', 'FontSize', 8);
% %                 ylabel ('Cluster # with Q_{ci} /Q_{\Delta} ?Q_{si}', 'FontSize', 10);
% %                 ylim ([-0.6 4.6]);
%                 xlabel('EGG cycle time (%)', 'FontSize', 8);
%                 % ylabel ('Cluster # with Q_{ci} and /dEGG_{maxN}', 'FontSize', 10);
%                 title ('Q_{ci}               /Q_{\Delta}              ?Q_{si}', 'FontSize', 10, 'Interpreter', 'tex');
%                 ylabel ('Cluster #', 'FontSize', 10);
%                 ylim ([-0.6 4.6])
            end
            drawnow
         end
    end
%    f.PaperOrientation = 'landscape';
%    print('-painters','-dpdf', printpathname);
%    close(f);
%    fprintf(fStats, '\r\n');
%end
%fclose(fStats);

%% SECTION B0: Compile one clusters file for each group
% Files '{F||M|G|B}-clusters.csv' were prepared manually in Excel
% by opening the *_gamma_VRP.csv file, which is sorted by Total descending, 
% finding the maxCluster # on row 1, 
% getting that row from the corresponding _clusters.csv file,
% and appending it into cat-clusters.csv

cond = '-3SR';

for cat = 1 : 4
    if cat < 3
        trimdir = trimdirA;
        finaldir = finaldirA;
    else
        trimdir = trimdirC;
        finaldir = finaldirC;
    end

    U = ones(1,31);
    tableRow = 1;

    for person = includeSubjects{cat}
        % load the Total-sorted gamma VRP file
        subject = [categs{cat} num2str(person, formatSpec)];
        gammavrpfilename = [subject '_gamma_VRP.csv'];
        vrppathname = fullfile(finaldir, subject, gammavrpfilename); 
        [n, vv] = FonaDynLoadVRP(vrppathname);
        colMaxCluster = find(ismember(n, 'maxCluster'));     
        maxCluster = vv(1,colMaxCluster);

        % load the cluster data file
        clusterfilename = fullfile(trimdir, subject, [subject cond '_clusters.csv']);
        T = readtable(clusterfilename, 'Delimiter', ';');
        % get the line for the most common cluster
        cData = T{maxCluster, :};
        U(tableRow,:) = cData(:);
        tableRow = tableRow + 1;
    end
    outfile = fullfile(tempdir, [categs{cat} '-clusters.csv'])
    dlmwrite (outfile, U, 'delimiter', ';', 'precision', 10);
end
%% SECTION B: Plot waveshapes of all F and all M
% NOT Sorted by increasing Qci

cat = 4;
grp = categs{cat};

clustfilename = fullfile(tempdir, [grp '-clusters.csv']);
[egg, Qc, Qs, maxDegg, Ic, ampl] = synthEGGfromFile(clustfilename, 100, 2);
% [Qv, ix] = sort(Qc);
% ix = 1:3; Qv = Qc;
% mD = maxDegg;
% mS = Qs;

% egg2 = egg(:,ix);
% egg = [egg (ones(200,4).* -50)] ;  % for the 9 boys only
%egg = [egg (ones(200,2).* -50)] ;  % for the 11 girls only

f = figure('Units', 'normalized','Color', 'white','Position', [0.1, 0.1, 0.14, 0.75]);
plotEGG(egg, grp, f); % ??
ylabel('Participant');
ylim ([-0.8, 12.8]);

N = length(Qc);
colors = colormapFD(N, 0.7);
for i = 1 : 0
    sD = 0.015;  % shadow offset
    nD = 0;
    color = colors(i, :)*0.6;
    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), Qc(i));
    text(3+sD, 12.9-i-sD, lStr{i}, 'FontSize', 8);
    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
    text(100+sD, 13.1-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}?%0.3g',  color(1), color(2), color(3), Qs(i));
    %lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}?%0.3g ',  color(1), color(2), color(3), ix(i));
    text(155+sD, 13.3-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'left');

    color = [0 0 0]; %colors(i, :);
    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), Qc(i));
    text(3, 12.9-i, lStr{i}, 'FontSize', 8);
    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
    text(100, 13.1-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}?%0.3g ',  color(1), color(2), color(3), Qs(i));
    %lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}?%0.3g ',  color(1), color(2), color(3), ix(i));
    text(155+sD, 13.3-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'left');
    %ylim ([-0.8, 12.8])
end



%% SECTION C: Plot before/after and ratio-VRP for two metrics
for p = 10:-1:6
person = p;
subject = ['S' num2str(person)];
threshold = 3; % min cycles required for plot

f = figure('Units', 'normalized','Color', 'white','Position', [0.1, 0.1, 0.4, 0.45]);
range = [55 85 50 110];
grid on

vrpfig = figure(f);
box on ; grid on;

tStr = sprintf('SPL @ 0.3 m (dB)  Threshold: %d cycles per cell', threshold);
metrics = {'Icontact', 'Crest'};  % Two metrics
w = size(metrics, 2);
for r = 1 : 2
    % Load the '_before' VRP
    vrpfilename = [subject conds{1} '_VRP.csv'];
    vrppathname = fullfile(editdir, subject, vrpfilename); 
    [n, v1] = FonaDynLoadVRP(vrppathname);
    
    % Load the '_after' VRP
    vrpfilename = [subject conds{2} '_VRP.csv'];
    vrppathname = fullfile(editdir, subject, vrpfilename); 
    [n, v2] = FonaDynLoadVRP(vrppathname);
    
    box on; grid on;
    metric = metrics{r};

    p = 1 + 3*(r-1);
    ax = subplot(w,3,p);  
    pbaspect(ax, [2 1 1]);
    FonaDynPlotVRP(v1, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, 'Range', range, ...
        'PlotHz', 'on', 'OffsetSPL', splCals(person));
    title ([subject conds{1}], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
    % xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
    xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
    ylabel (ax, tStr, 'FontSize', 8);
    
    p = 2 + 3*(r-1);
    ax = subplot(w,3,p);  
    pbaspect(ax, [2 1 1]);
    FonaDynPlotVRP(v2, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, 'Range', range, ...
        'PlotHz', 'on', 'OffsetSPL', splCals(person));
    title ([subject conds{2}], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
%    xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
    xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
    drawnow

    p = 3 + 3*(r-1);
    ax = subplot(w,3,p);  
    pbaspect(ax, [2 1 1]);
    FonaDynPlotVRPratios(v1, v2, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, 'Range', range, ...
        'PlotHz', 'on', 'OffsetSPL', splCals(person));
%    title ([subject cond{2}], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
    % xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
    title ('After/Before', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
    xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
    drawnow
end
end

%% SECTION D: Comparison of Qci and CQegg ad modum Howard 
category = 4;
threshold = 5; % min cycles required for plot
fStatsName = fullfile(tempdir, ['CQfits-' categs{category} '.csv'])
fitMat = zeros(13,4);

if category < 3
    trimdir = trimdirA;
    finaldir = finaldirA;
else
    trimdir = trimdirC;
    finaldir = finaldirC;
end

for person = includeSubjects{category}
    %person = p;
    subject = [categs{category} num2str(person, formatSpec)];

    f = figure('Units', 'normalized','Color', 'white','Position', [0.1, 0.1, 0.6, 0.675]);
    range = rangesVRP(category,:);
    grid on

    vrpfig = figure(f);
    box on ; grid on;

    tStr = sprintf('SPL @ 0.3 m (dB) Threshold: %d cycles', threshold);
    metrics = {'Qcontact', 'Icontact'};  % Two metrics
    % Load the VRP with Qci
    vrpfilename = [subject conds{2} '_fine_VRP.csv'];
    vrppathname = fullfile(finaldir, subject, vrpfilename); 
    [n, v1] = FonaDynLoadVRP(vrppathname);

    % Load the VRP with CQegg ad modum Howard
    vrpfilename = [subject conds{2} '_fine_CQ_VRP.csv'];
    vrppathname = fullfile(finaldir, subject, vrpfilename); 
    [n, v2] = FonaDynLoadVRP(vrppathname);
    
    % Build the clusters file name
    clusterfilename = [subject conds{2} '_clusters.csv'];
    clusterpathname = fullfile(trimdir, subject, clusterfilename); 

    box on; grid on;
    metric = metrics{1};

    p = 1; % + 3*(r-1);
    ax = subplot(2,3,1);  
    pbaspect(ax, [2 1 1]);
    FonaDynPlotVRP(v1, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, 'Range', range, ...
        'PlotHz', 'on');
    title ([subject conds{2}], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
    % xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
    xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
    ylabel (ax, tStr, 'FontSize', 8);
    grid on

    p = 2; % + 3*(r-1);
    ax = subplot(2,3,2);  
    pbaspect(ax, [2 1 1]);
    FonaDynPlotVRP(v2, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, 'Range', range, ...
        'PlotHz', 'on', 'Special', 1);
    title ([subject conds{2}], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
%    xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
    xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
    grid on
    drawnow

    p = 3; % + 3*(r-1);
    ax = subplot(2,3,p);  
    pbaspect(ax, [2 1 1]);
    FonaDynPlotVRPdiffs(v1, v2, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, 'Range', range, ...
        'PlotHz', 'on');
%    title ([subject cond{2}], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
    title ('CQ_{EGG}-Q_{ci}', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
    xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
    grid on
    drawnow

    p = 4;
    colTot = find(ismember(n, 'Total'));
    colPlot = find(ismember(n, metric)); 
    ax = subplot(2,3,p);
    %threshIx = find((v1(:,colTot) >= threshold) & (v2(:,colPlot) > v1(:,colPlot)-0.08));
    threshIx = find(v1(:,colTot) >= threshold); 
    qciegg = v1(threshIx,colPlot);
    cqegg = v2(threshIx,colPlot);
    weights = v1(threshIx, colTot);
    %plot(cqegg, qciegg, '.b');
    fitLine = fitlm(cqegg, qciegg,'linear','Weights', weights);
    fitLine.plot
    fitMat(person,:) = [person fitLine.Coefficients.Estimate(2) fitLine.Coefficients.Estimate(1) fitLine.Rsquared.Ordinary];

    xlabel('CQ_{EGG}');
    ylabel('Q_{ci}');
    grid on
    drawnow
    
    p = 5;
    ax = subplot(2,3,p);  
    FonaDynPlotVRP(v2, n, 'maxCluster', vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, 'Range', range, ...
        'PlotHz', 'on');
    title ([subject conds{2}], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
    xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
    grid on
    drawnow
    
    p = 6;
    ax=subplot(2,3,p); 
    [egg, Qc, maxDegg, Ic, ampl] = synthEGGfromFile(clusterpathname, 100, 2);
    plotEGG(egg, clusterfilename, vrpfig);
    N = length(Qc);
    colors = colormapFD(N, 0.7);
    for i = 1 : N
        sD = 0.015;  % shadow offset
        color = colors(i, :)*0.6;
        lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), Qc(i));
        text(3+sD, 4.9-i-sD, lStr{i}, 'FontSize', 8);
        lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
        text(100+sD, 5.1-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');

        color = colors(i, :);
        lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), Qc(i));
        text(3, 4.9-i, lStr{i}, 'FontSize', 8);
        lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
        text(100, 5.1-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
    end
    ylim(ax,[-0.6 N-0.4]); 
    title ([subject conds{2}], 'interpreter','none', 'FontWeight', 'normal');
    xlabel('EGG cycle time (%)', 'FontSize', 8);
    ylabel ('Cluster # with \itQ_{ci}\rm and /\itQ_{\Delta}\rm', 'FontSize', 8);
end

dlmwrite(fStatsName, fitMat, ';');

%% SECTION E:  Make new _VRP files from log files, 
% with Ic, Qci, Qdelta and Qsi computed from the FDs instead of the time signal

cond = '_VRP';  
csvFix = '-full_fine_CQ_VRP.csv';  % with tweaked SampEn, and SpecBal, and Qspeed inserted
% cond = '_VRP';  
%csvFix = '-full_FD4_VRP.csv';  % with Gibbs
category = 4;

if category < 3
    trimdir = trimdirA;
    finaldir = finaldirA;
else
    trimdir = trimdirC;
    finaldir = finaldirC;
end

for person = includeSubjects{category}
    subject = [categs{category} num2str(person, formatSpec)];
    workdir = fullfile(finaldir, subject);  % finaldir is where the latest log files are
    searchFileStr = fullfile(workdir, ['*_' subject cond '?_C_Log.aiff']);
    logfilenames = ls (searchFileStr);
    logdata = [];
    for lf = 1 : size(logfilenames,1)
       fName = fullfile(workdir, logfilenames(lf,:)); 
       %md = augment4LogFile(fName,0);
       % md = augment8LogFile(fName,0);   % With SpecBal and inserts Qspeed
       md = augment9LogFile(fName,0);   % as #8 but with CQ-Howard instead of Qci
       logdata = [logdata; md];
    end
    
    startIx = 1;
    if (cond(2) == 'S')  % skip the sustained vowels at the start of SRPs
        startIx = find(logdata(:,1) > startTimes(category, person), 1);
    end
    [names, p1, v1] = FonaDynArraysLogFileToVRP(logdata(startIx:end,:), nClusters); %Assumes Qspeed included
    csvFileName = [subject csvFix];
    csvFilePath = fullfile(finaldir, subject, csvFileName)
    FonaDynSaveVRP(csvFilePath, names, v1);
end

%% SECTION F: Run regression analyses on all cycles in the individual regions 
%  (no stratification into voice map cells)
%  and store the results in a large table with one row per subject

tRow=1;
tArray = zeros(46,16);
nameList = {};

cond = '_VRP';  
%condOptions = '-3SR_fine';

for cat = 1:4
    if cat < 3
        trimdir = trimdirA;
        finaldir = finaldirA;
    else
        trimdir = trimdirC;
        finaldir = finaldirC;
    end

%   cols = [8, 10, 11, 12]; % Columns for SampEn, Qdelta, Qci and Qsi
    cols = [11, 10, 12, 8]; % Columns for Qci, Qdelta, Qsi and CSE
    
    for person = includeSubjects{cat} 
        subject = [categs{cat} num2str(person, formatSpec)]
        workdir = fullfile(finaldir, subject);
        matFileName = fullfile(workdir, [subject '_gamma2.mat']); 
        load (matFileName);
        n = size(gammaData,1);
        Y = gammaData(:,cols);   

        % Regress over fo only to compute the slopes
        X = [ones(n,1), gammaData(:,2)];
        [betaF, SigmaF, residualsF] = mvregress(X, Y, 'algorithm', 'cwls'); 
        % betaF(2, :) are the four slopes

        % Regress over spl only to compute those slopes
        X = [ones(n,1), gammaData(:,3)];
        [betaL, SigmaL, residualsL] = mvregress(X, Y, 'algorithm', 'cwls'); 
        % betaL(2, :) are the four slopes

        % Regress over both fo and spl 
        % to compute the variances explained by both
        % X = [ones(n,1), gammaData(:,2:3)];
        % [beta, Sigma, residuals] = mvregress(X, Y, 'algorithm', 'cwls'); 

        % Stats for Qd, Qci, Qsi and CSE
        for k = 1:4
            Means(k)     = mean(gammaData(:,cols(k)));
            Stds(k)      =  std(gammaData(:,cols(k)));
            slopesF(k)   = betaF(2, k);
            slopesL(k)   = betaL(2, k);

            tArray(tRow,1+(k-1)*4) = Means(k);
            tArray(tRow,2+(k-1)*4) = Stds(k);
            tArray(tRow,3+(k-1)*4) = slopesF(k);
            tArray(tRow,4+(k-1)*4) = slopesL(k);
        end
        nameList{tRow} = subject;
        tRow = tRow+1;
    end
end

% colNames = {'SEnMean','SEnSD','SEnKfo','SEnKSPL','SEnVexpl', ...
%             'QdMean',  'QdSD', 'QdKfo', 'QdKSPL', 'QdVexpl', ...
%             'QciMean','QciSD','QciKfo','QciKSPL','QciVexpl', ...
%             'QsiMean','QsiSD','QsiKfo','QsiKSPL','QsiVexpl'
%             };
% 
colNames = {'QciMean','QciSD','QciKfo','QciKSPL', ...
            'QdMean',  'QdSD', 'QdKfo', 'QdKSPL', ...
            'QsiMean','QsiSD','QsiKfo','QsiKSPL', ...
            'CSEMean','CSESD','CSEKfo','CSEKSPL'
            };

T = array2table(tArray, 'RowNames', nameList', 'VariableNames', colNames);
tableFileName = fullfile(tempdir, ['Stats5' cond '-regions.csv']);
writetable(T, tableFileName, 'Delimiter', ';', 'WriteRowNames', 1);

%% SECTION H: Plot 1..4 SRPs for JSHLR article, Figure 2
%  with optional gamma region and statistics log
bGamma = 1;

cond = '-3SR';  
condOptions = '_FD2';
cat = 4;

if cat < 3
    trimdir = trimdirA;
else
    trimdir = trimdirC;
end

if bGamma > 2
    fStr = [categs{cat} cond condOptions '-statistics.csv'];
    statsfile = fullfile(trimdir, fStr);
    fStats = fopen(statsfile, 'a');
    header = 'Subject;fo.mean Hz;fo.std ST;L.mean dB;L.std dB;Qci.mean;Qci/ST;Qci/dB;Qsi.mean;Qsi/ST;Qsi/dB;Qd.mean;Qd/ST;Qd/dB;Ic.mean;Ic/ST;Ic/dB;Crest.mean;Crest/ST;Crest/dB;TotCycles';
    fprintf(fStats, '%s\r\n', header);
end

for person = 2:2
    subject = [categs{cat} num2str(person, formatSpec)];
    outdir  = fullfile(trimdir, subject);
    clusterfilename = [subject cond '_clusters.csv'];
    workdir = fullfile(trimdir, subject);
    clusterpathname = fullfile(workdir, clusterfilename); 
    printpathname = fullfile(tempdir, [subject cond condOptions '.pdf']);

    vrpfilename = [subject cond condOptions '_VRP.csv'];    
    vrppathname = fullfile(workdir, vrpfilename); 
    [n, vv] = FonaDynLoadVRP(vrppathname);

    vrpfilename = [subject '-full' condOptions '_VRP.csv'];    
    vrppathname = fullfile(workdir, vrpfilename); 
    [n, vrp] = FonaDynLoadVRP(vrppathname);

    threshold = 5; % min cycles required for plot

    if bGamma > 0
        topPercent = 50;
        v1 = skimVRP(vv,n,topPercent, 0);
        v2 = skimVRP(vv,n,topPercent, 1);
%        logStats(subject,v,n,fStats);
    end
    
    v{1} = {}; 
    v{2} = {v1, v2};  %% requires a mod in FonaDynPlotVRP.m
    v{3} = {v2};
    v{4} = {v2};
    
    plotHz{1} = {'on'};
    plotHz{2} = {'on'};
    plotHz{3} = {'on'};
    plotHz{4} = {'on'};
    xLabels{1} = {'\it f\rm_o (Hz)'};
    xLabels{2} = {'\it f\rm_o (Hz)'};
    xLabels{3} = {'\it f\rm_o (Hz)'};
    xLabels{4} = {'\it f\rm_o (Hz)'};
    thresholds = [1 5 5 5];

    f = figure('Units', 'normalized','Color', 'white','Position', [0.1, 0.1, 0.6, 0.25], ...
        'PaperPosition', [0, 0, 27, 21]);

    vrpfig = figure(f);
    grid on 
    range = rangesSRP(cat, :);
    box on 

    %metrics = {'Qcontact', 'dEGGmax', 'Crest'};
    %metrics = {'Total', 'Entropy', 'Crest'; 'Qcontact', 'dEGGmax', 'Qspeed'; 'Icontact' 'maxCluster', 'Total'};
    metrics = {'Total', 'Total', 'Total', 'dEGGmax'};
    tStr = 'SPL @ 0.3 m, dB(C)';
   
    h = size(metrics, 1);
    w = size(metrics, 2);

    for c = 1 : h
        for m = 1 : w
            metric = metrics{c,m};
            left = m*0.25 + 0.02;
            p = m + w*(c-1);
            ax = subplot(h,w,p);  %, 'position', [left 0.12 0.22 0.8]);
            % ax = subplot(1,1,p);  %, 'position', [left 0.12 0.22 0.8]);
            if (m < 4)
                map = vv;
            else
                map = vrp;
                range = rangesVRP(cat, :);
            end
            if p < 9
                pbaspect(ax, [2 1 1]);
                FonaDynPlotVRP(map, n, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', thresholds(m), ... 
                    'Range', range, 'PlotHz', plotHz{m}, 'Special', 1, 'Region', v{m});
                box on; grid on;
                title ([subject cond], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');
                xlabel(xLabels{m}, 'FontSize', 10);
                if m == 1 
                    ylabel (tStr, 'FontSize', 10);
                end
            else
                pbaspect(ax, [1 1 1]);
                [egg, Qci, Qsi, maxDegg, Ic, ampl] = synthEGGfromFile(clusterpathname, 100, 2);
                plotEGG(egg, clusterfilename, ax);
                N = length(Qci);
                colors = colormapFD(N, 0.7);
                for i = 1 : N
                    sD = 0.015;  % shadow offset
                    color = colors(i, :)*0.6;
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), Qci(i));
                    text(3+sD, 4.9-i-sD, lStr{i}, 'FontSize', 8);
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
                    text(100+sD, 5.1-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}?%0.3g ',  color(1), color(2), color(3), Qsi(i));
                    text(160+sD, 5.3-i-sD, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'left');

                    color = colors(i, :);
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}%5.2f ', color(1), color(2), color(3), Qci(i));
                    text(3, 4.9-i, lStr{i}, 'FontSize', 8);
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}/%0.3g ',  color(1), color(2), color(3), maxDegg(i));
                    text(100, 5.1-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'right');
                    lStr{i} = sprintf('\\color[rgb]{%f,%f,%f}?%0.3g ',  color(1), color(2), color(3), Qsi(i));
                    text(160, 5.3-i, lStr{i}, 'FontSize', 8, 'HorizontalAlignment', 'left');

                end
                %legend(lStr, 'Location', 'northwest', 'Box', 'off'); 
                xlabel('EGG cycle time (%)', 'FontSize', 8);
                % ylabel ('Cluster # with Q_{ci} and /dEGG_{maxN}', 'FontSize', 10);
                ylabel ('Cluster # with Q_{ci}  /Q_{\Delta}  Q_{si}', 'FontSize', 10);
                ylim ([-0.6 4.6])
            end
            drawnow
         end
    end
    %f.PaperOrientation = 'landscape';
    %print('-painters','-dpdf', printpathname);
    %close(f);
    if bGamma > 3
         fprintf(fStats, '\r\n');
    end
end

%% SECTION J - Build a FonaDyn script file for each group
%  The drive C: is used for output, to somewhat reduce network bandwidth,
%  so the results must be transferred later to L:

outputBaseDir = 'C:/Recordings/KinderEGG';
conds = {'-3SR', '-full'};
ftypes = {'_SRP', '_VRP'};
condOptions = '_raw';

cat = 4;    % choose group here

if cat < 3
    workDir = trimdirA;
else
    workDir = trimdirC;
end

runCmd = 'HOLD';

fStr = [categs{cat} '-script.txt'];
scriptfile = fullfile(tempdir, fStr);
fScript = fopen(scriptfile, 'w');
header = { 
    'io.inputType=1', ...
    'sampen.amplitudeTolerance=0.1', ...
    'sampen.phaseTolerance=0.2',  ...
    'sampen.amplitudeHarmonics=4', ...
    'sampen.phaseHarmonics=4', ...
    'sampen.bDrawSampEn=true', ...
    'scope.duration=4', ...
    'io.keepInputName=true', ...
    'io.enabledWriteLog=true', ...
    'io.writeLogFrameRate=0' };
for i = 1 : size(header,2)
    fprintf(fScript, '%s\r\n', header{i});
end

for person = subjectNumbers(1, cat) : subjectNumbers(2, cat)
    subject = [categs{cat} num2str(person, formatSpec)];
    % SClang wants forward slashes in paths
    fprintf(fScript, 'general.output_directory="%s/%s"\r\n', outputBaseDir, subject); 

    for c = 1 : 2
        cond = conds{c};
        ftype = ftypes{c};

        % Build the subject's preamble
        % Get filenames from the Matlab environment
        fprintf(fScript, 'LOAD "%s/%s/%s%s_clusters.csv"\r\n', workDir, subject, subject, cond); 
        preamble = {
            'cluster.initialize=true', ...
            'cluster.learn=false', ...
            'cluster.reset=false', ...
            'io.keepData=false' };
        for i = 1 : size(preamble,2)
            fprintf(fScript, '%s\r\n', preamble{i});
        end
        
        % Get the .wav file names for this subject
        searchFileStr = fullfile(workDir, subject, ['*_' subject ftype '?_C_Voice_EGG.wav']);
        wavfilenames = ls (searchFileStr);
        for lf = 1 : size(wavfilenames,1)
            fprintf(fScript, 'io.filePathInput="%s/%s/%s"\r\n', workDir, subject, wavfilenames(lf,:)); 
            fprintf(fScript, '%s\r\n', runCmd);
            if lf < size(wavfilenames,1)
                fprintf(fScript, 'io.keepData=true\r\n');
            end
            runCmd = 'RUN';
        end
        fprintf(fScript, 'SAVE "%s/%s/%s%s%s_VRP.csv"\r\n', outputBaseDir, subject, subject, cond, condOptions); 
    end
end
fclose(fScript);

%% SECTION K   Generate random outcomes and plot Student's t

T = readtable(fullfile(tempdir, 'V_VRP-stats.csv'));

meansInput = table2array(T(:,12)); % 12 is Qci, 17 is Qsi 
sdInput    = table2array(T(:,13));
aVector = zeros(13,1); % Number of male  subjects
bVector = zeros(22,1); % Number of child subjects

[~, nominal] = ttest2(meansInput(1:26), meansInput(27:48));

count = 1000;
probs = zeros(count,4);

for k = 1:count
    r1Vector = randn(26,1);
    r2Vector = randn(22,1);
    for M = 1:26
       aVector(M) = meansInput(M) + sdInput(M) * r1Vector(M);
    end
    for C = 1:22
       bVector(C) = meansInput(C+26) + sdInput(C+26) * r2Vector(C);
    end
    [~, prob] = ttest2(aVector, bVector);
    probs(k,1) = prob;
    probs(k,2) = nominal;
    probs(k,3) = mean(aVector);
    probs(k,4) = mean(bVector);
end

x = 1:count;
figure(1);
ax = gca;
yyaxis (ax, 'left');
plot(x, probs(:,1), '.k', x, probs(:,2), 'g--');
ylim (ax, [0 1]);
%hold
yyaxis (ax, 'right');
plot(x, probs(:,3), 'b-', x, probs(:,4), 'r-');
ylim (ax, [0 0.5]);

[b, ix] = sort(probs(:,1));
probs2 = probs(ix, :);

figure(2);
ax = gca;
yyaxis (ax, 'left');
plot(x, probs2(:,1), '.k', x, probs2(:,2), 'g--');
ylim (ax, [0 1]);
%hold
yyaxis (ax, 'right');
plot(x, probs2(:,3), 'b-', x, probs2(:,4), 'r-');
ylim (ax, [0 0.5]);


%% SECTION L:  Make union VRPs per group, from VRP files 

cond = '_VRP';  
csvFix = '-full_fine_VRP.csv';  % with tweaked SampEn, and SpecBal, and Qspeed inserted
%csvFix = '_gamma_VRP.csv';  % with tweaked SampEn, and SpecBal, and Qspeed inserted
group = 3;
threshInclPart = 5; % min cycles/cell required for participation in the group
%threshInclStats = 10; % min participants/cell for computing group statistics

if group < 3
    finaldir = finaldirA;
else
    finaldir = finaldirC;
end

matAccumulate = zeros(15, 66, 80);

for person = includeSubjects{group}
    subject = [categs{group} num2str(person, formatSpec)];
    workdir = fullfile(finaldir, subject);  
    vrpfilename = [subject csvFix];    
    vrppathname = fullfile(finaldir, subject, vrpfilename); 
    [names, vrp] = FonaDynLoadVRP(vrppathname);
    matParticipant = FonaDynMatrixFromVRP(vrp, threshInclPart);
    matAccumulate = matAccumulate + matParticipant;
end

if group == 3   % append boys to girls
    group = 4;
    for person = includeSubjects{group}
        subject = [categs{group} num2str(person, formatSpec)];
        workdir = fullfile(finaldir, subject);  
        vrpfilename = [subject csvFix];    
        vrppathname = fullfile(finaldir, subject, vrpfilename); 
        [names, vrp] = FonaDynLoadVRP(vrppathname);
        matParticipant = FonaDynMatrixFromVRP(vrp, threshInclPart);
        matAccumulate = matAccumulate + matParticipant;
    end
end
   

matAccumulate(1:9,:,:) = matAccumulate(1:9,:,:) ./ matAccumulate(10,:,:); % compute mean of most cols
matAccumulate(1,:,:)  = matAccumulate(10,:,:);  % put # of part's in col Total
[~,matAccumulate(10,:,:)] = max(matAccumulate(11:15,:,:));  % recompute the maxCluster column

v1 = FonaDynVRPFromMatrix(matAccumulate);
csvfilename = [categs{group} cond '-union_VRP.csv'];
%csvfilename = [categs{group} cond '-union_gamma_VRP.csv'];
csvfilepath = fullfile(tempdir, csvfilename)
FonaDynSaveVRP(csvfilepath, names, v1);

%% SECTION L2:  Make total VRPs of all groups, from group union VRP files 

cond = '_VRP';  
%csvFix = '-full_fine_VRP.csv';  % with tweaked SampEn, and SpecBal, and Qspeed inserted
csvFix = '_VRP-union_VRP.csv';  % with tweaked SampEn, and SpecBal, and Qspeed inserted
group = 1;
threshInclPart = 5; % min cycles/cell required for participation in the group
%threshInclStats = 10; % min participants/cell for computing group statistics

matAccumulate = zeros(15, 66, 80);

for group = [1 2 4]
    if group < 3
        finaldir = finaldirA;
    else
        finaldir = finaldirC;
    end
    vrpfilename = [categs{group} csvFix];    
    vrppathname = fullfile(finaldir, vrpfilename); 
    [names, vrp] = FonaDynLoadVRP(vrppathname);
    matParticipant = FonaDynMatrixFromVRP(vrp, threshInclPart);
    matAccumulate = matAccumulate + matParticipant;
end   

matAccumulate(1:9,:,:) = matAccumulate(1:9,:,:) ./ matAccumulate(10,:,:); % compute mean of most cols
matAccumulate(1,:,:)  = matAccumulate(10,:,:);  % put # of part's in col Total
[~,matAccumulate(10,:,:)] = max(matAccumulate(11:15,:,:));  % recompute the maxCluster column

fig = figure(1);

v1 = FonaDynVRPFromMatrix(matAccumulate);
FonaDynPlotVRP(v1, names,'SpecBal', fig, 'Range', rangesVRP(1,:), 'MinCycles', 1, 'PlotHz', 'on');
%csvfilename = [categs{group} cond '-union_VRP.csv'];
csvfilename = 'All-union_VRP.csv';
csvfilepath = fullfile(tempdir, csvfilename)
FonaDynSaveVRP(csvfilepath, names, v1);
%% SECTION M - plot group union VRPs and delta-VRPs

groups = ['M', 'F', 'C'];
cond = '_VRP';
workdir = 'L:/fonadyn/KinderEGG';
threshold = 3; % minimum number of PARTICIPANTS as coded in these union VRPs
ranges = rangesVRP;


% Load the union VRPs
vrpMname = fullfile(workdir, 'adults-final',   ['M' cond '-union_VRP.csv']);
vrpFname = fullfile(workdir, 'adults-final',   ['F' cond '-union_VRP.csv']);
vrpCname = fullfile(workdir, 'children-final', ['B' cond '-union_VRP.csv']);

[names, vrpM] = FonaDynLoadVRP(vrpMname); 
[~,     vrpF] = FonaDynLoadVRP(vrpFname); 
[~,     vrpC] = FonaDynLoadVRP(vrpCname); 

% Load the corresponding union gamma-region VRPs
vrpMGname = fullfile(workdir, 'adults-final',   ['M' cond '-union_gamma_VRP.csv']);
vrpFGname = fullfile(workdir, 'adults-final',   ['F' cond '-union_gamma_VRP.csv']);
vrpCGname = fullfile(workdir, 'children-final', ['B' cond '-union_gamma_VRP.csv']);

[names, vrpMG] = FonaDynLoadVRP(vrpMGname); 
[~,     vrpFG] = FonaDynLoadVRP(vrpFGname); 
[~,     vrpCG] = FonaDynLoadVRP(vrpCGname); 


f = figure('Units', 'normalized','Color', 'white','Position', [0.1, 0.1, 0.5, 0.55], ...
    'PaperPosition', [0, 0, 27, 17]);

vrpfig = figure(f);
grid on 
box on 

tStr = sprintf('SPL @0.3m(dB) Min %i participants', threshold);
metrics = {'Qcontact', 'dEGGmax', 'Qspeed', 'Entropy', 'Icontact', 'Crest', 'SpecBal', 'Total'};

diffRanges = [ -0.1, 0.1; -2, 2; -1, 1; -1, 1; -0.1, 0.1; -1, 1; -10, 10; -100 100]; 

h = 2;
w = 3;

vv = {vrpM, vrpF, vrpC};
vr = {vrpMG, vrpFG, vrpCG};
vrd = {vrpFG, vrpCG, vrpCG};

pairs = [1 2 1; 2 3 3]; 

for nMetric = 1 : 4
    for m = 1 : w
        metric = metrics{nMetric};
        p = m ;
        ax = subplot(h,w,p);  
        pbaspect(ax, [2 1 1]);
        FonaDynPlotVRP(vv{m}, names, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, ... 
            'Range', ranges(m,:), 'PlotHz', 'on', 'Special', 0, 'Region', vr{m});
        box on; grid on;
        title (['Union ' groups(m)], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');        %xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
        xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
        if m==1
            ylabel (tStr, 'FontSize', 8);
        end
        drawnow
    end
    for m = 1 : w
        m2 = mod(m, 3) + 1;
        metric = metrics{nMetric};
        p = m + w;
        ax = subplot(h,w,p);  
        pbaspect(ax, [2 1 1]);
        % FonaDynPlotVRPdiffs(sArray1, sArray2, colNames, colName, fig, varargin)
        dr = diffRanges(nMetric, :);
        FonaDynPlotVRPdiffs(vv{pairs(1, m)}, vv{pairs(2, m)}, names, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, ... 
            'Range', ranges(m,:), 'PlotHz', 'on', 'DiffRange', dr); %, 'Region', vrd{m});
        box on; grid on;
        hstr = sprintf("Difference %c-%c", groups(pairs(2, m)), groups(pairs(1, m)));
        title (hstr, 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');        %xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
        xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
        if m==1
            ylabel (tStr, 'FontSize', 8);
        end
        drawnow
    end
    printpathname = fullfile(tempdir, ['Diffs-gamma-' metric cond '.pdf']);
    f.PaperOrientation = 'landscape';
    print('-painters','-dpdf', printpathname);
    % close(f);
end

%% SECTION N: create union VRPs of the three groups 
%  with only the cells filled by at least <threshold> participants from
%  every group.
% 

groups = ['M', 'F', 'C'];
cond = '_VRP';
workdir = 'L:/fonadyn/KinderEGG';
threshold = 3; % minimum number of PARTICIPANTS as coded in these union VRPs
ranges = rangesVRP;


% Load the union VRPs
vrpMname = fullfile(workdir, 'adults-final',   ['M' cond '-union_VRP.csv']);
vrpFname = fullfile(workdir, 'adults-final',   ['F' cond '-union_VRP.csv']);
vrpCname = fullfile(workdir, 'children-final', ['B' cond '-union_VRP.csv']);

[names, vrpM] = FonaDynLoadVRP(vrpMname); 
[~,     vrpF] = FonaDynLoadVRP(vrpFname); 
[~,     vrpC] = FonaDynLoadVRP(vrpCname); 
vv = {vrpM, vrpF, vrpC};

% Load the corresponding union gamma-region VRPs
vrpMGname = fullfile(workdir, 'adults-final',   ['M' cond '-union-gamma_VRP.csv']);
vrpFGname = fullfile(workdir, 'adults-final',   ['F' cond '-union-gamma_VRP.csv']);
vrpCGname = fullfile(workdir, 'children-final', ['B' cond '-union-gamma_VRP.csv']);
 
[names, vrpMG] = FonaDynLoadVRP(vrpMGname); 
[~,     vrpFG] = FonaDynLoadVRP(vrpFGname); 
[~,     vrpCG] = FonaDynLoadVRP(vrpCGname); 

intersectA = cropVRPwithThreshold(vrpM, vrpF, threshold);
intersectVRP = cropVRPwithThreshold(intersectA, vrpC, threshold);

csvfilename = 'Groups-intersect-union_VRP.csv';
csvfilepath = fullfile(tempdir, csvfilename)
FonaDynSaveVRP(csvfilepath, names, intersectVRP);

vrpMX = cropVRP(intersectVRP, vrpM);
vrpFX = cropVRP(intersectVRP, vrpF);
vrpCX = cropVRP(intersectVRP, vrpC);
vix = { vrpMX, vrpFX, vrpCX };
for k = 1 : 3
    csvfilename = [groups(k) '-union-intersect_VRP.csv'];
    csvfilepath = fullfile(tempdir, csvfilename);
    %guicVRP = cropVRP(vrpCG, vix{k});
    FonaDynSaveVRP(csvfilepath, names, vix{k});
end


f = figure('Units', 'normalized','Color', 'white','Position', [0.1, 0.1, 0.5, 0.55], ...
    'PaperPosition', [0, 0, 27, 17]);

vrpfig = figure(f);
grid on 
box on 

tStr = sprintf('SPL @0.3m(dB) Min %i participants', threshold);
metrics = {'Qcontact', 'dEGGmax', 'Qspeed', 'Entropy', 'Icontact', 'Crest', 'SpecBal', 'Total'};

diffRanges = [ -0.1, 0.1; -2, 2; -1, 1; -2, 2; -0.1, 0.1; -1, 1; -10, 10; -100 100]; 

h = 2;
w = 3;

vr = {vrpMG, vrpFG, vrpCG};
vrd = {vrpFG, vrpFG, vrpFG};

pairs = [1 2 1; 2 3 3]; 

for nMetric = 1 : 7
    for m = 1 : w
        metric = metrics{nMetric};
        p = m ;
        ax = subplot(h,w,p);  
        pbaspect(ax, [2 1 1]);
        FonaDynPlotVRP(vv{m}, names, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, ... 
            'Range', ranges(m,:), 'PlotHz', 'on', 'Special', 1, 'Region', vr{m});
        box on; grid on;
        title (['Union ' groups(m) cond], 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');        %xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
        xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
        if m==1
            ylabel (tStr, 'FontSize', 8);
        end
        drawnow
    end
    for m = 1 : w
        m2 = mod(m, 3) + 1;
        metric = metrics{nMetric};
        p = m + w;
        ax = subplot(h,w,p);  
        pbaspect(ax, [2 1 1]);
        % FonaDynPlotVRPdiffs(sArray1, sArray2, colNames, colName, fig, varargin)
        dr = diffRanges(nMetric, :);
        FonaDynPlotVRPdiffs(vix{pairs(1, m)}, vix{pairs(2, m)}, names, metric, vrpfig, 'ColorBar', 'on', 'MinCycles', threshold, ... 
            'Range', ranges(m,:), 'PlotHz', 'on', 'DiffRange', dr); %, 'Region', vrd{m});
        box on; grid on;
        hstr = sprintf("Diff %c-%c%s", groups(pairs(2, m)), groups(pairs(1, m)), cond);
        title (hstr, 'interpreter','none', 'FontWeight', 'normal', 'HorizontalAlignment', 'left');        %xlabel('\it f\rm_o (MIDI #)', 'FontSize', 8);
        xlabel('\it f\rm_o (Hz)', 'FontSize', 8);
        if m==1
            ylabel (tStr, 'FontSize', 8);
        end
        drawnow
    end
    printpathname = fullfile(tempdir, ['Diffs-overlap-' metric cond '.pdf']);
    f.PaperOrientation = 'landscape';
    print('-painters','-dpdf', printpathname);
    % close(f);
end

%% Section O  Plot several metrics vs SPL, from _VRP files

cat = 2;
if cat < 3
    finaldir = finaldirA;
    slicesdir = slicesdirA;
else
    finaldir = finaldirC;
    slicesdir = slicesdirC;
end

for person = 1:1 % includeSubjects{cat}
%     subject = [categs{cat} num2str(person, formatSpec)];
%     outdir  = fullfile(slicesdir, subject);
%     cond = '-full';  % cluster file is always '_before'
%     condOptions = '_fine';
%     % clusterfilename = [subject cond '_clusters.csv'];
%     workdir = fullfile(finaldir, subject);
%     % clusterpathname = fullfile(workdir, clusterfilename); 
    % printpathname = fullfile(tempdir, [subject cond condOptions '.pdf']);

    threshold = 5; % min cycles required for doing the graphs

    f = figure; %('Units', 'normalized','Color', 'white','Position', [0.1, 0.1, 0.6, 0.6], ...
                %'PaperPosition', [1, 0, 27, 19]);

    vrpfig = figure(1);
    grid on 
    range = rangesVRP(cat,:);
    box on 

 
    tStr = sprintf('SPL @0.3m(dB) Min %i cycles', threshold);
    %metrics = {'Qcontact', 'dEGGmax', 'Crest'};
    metrics = {'dEGGmax', 'Qcontact', 'Qspeed'; 'Total', 'maxCluster', 'Total'};

%     vrpfilename = [subject cond condOptions '_VRP.csv'];
%     vrppathname = fullfile(workdir, vrpfilename); 
vrppathname = 'H:\My Documents\Projects\Variability\Philly 2021 CoMeT\SEcal217k_VRP.csv'; 
    [n, vv] = FonaDynLoadVRP(vrppathname);
    vMatrix = FonaDynMatrixFromVRP(vv, threshold); 

    foMin  = 45-29; foMax  = 65-29;
    splMin = 42-39; splMax = 102-39;
    
    levels = (splMin:splMax)+39;
    scales = [0.1, 1, 1, 0.1, 1, 1, 1, 10];
    
    i = 1;
    for layer = [7] %[5, 6, 7, 4]
        [x, ~] = shiftdim(vMatrix(layer,:,:));
        for k = splMin : splMax
            aMetricMean(k-splMin+1) = scales(layer) * mean(x(:,k), 'omitnan');
            aMetricStdd(k-splMin+1) = scales(layer) * std(x(:,k),  'omitnan');
            theCellCounts(k-splMin+1) = size(x,1) - sum(isnan(x(:,k)));
        end
        plot(levels, aMetricMean, 'LineWidth', 2);
        hold on
        plot(levels, [aMetricMean+aMetricStdd; aMetricMean-aMetricStdd], 'k');
        lstrs{i}=n{layer+2};
        i = i+1;
    end  
%    plot(levels, theCellCounts*0.001, 'k');
    legend(lstrs,'Location','northwest');
    grid on
  %   f.PaperOrientation = 'landscape';
%   print('-painters','-dpdf', printpathname);
%   close(f);
end




