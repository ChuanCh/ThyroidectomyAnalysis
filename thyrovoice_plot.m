%% load in data
clear all; close all;
% addpath '/Volumes/voicelab/Huanchen/Thyrovoice Dataset/MATLAB_progs/matlab';
% kmeans++ clustering for kinderEGG

%audio_dir = '/Volumes/voicelab/Huanchen/Thyrovoice Dataset/audio/';
audio_dir = 'F:\Thyrovoice\audio';
new_vrp_dir = 'F:\Thyrovoice\New_VRP';
new_pdf_dir = 'F:\Thyrovoice\New_PDF';

patient_dir = dir(audio_dir);
pre_files = [];
post_files = [];
pre_data = [];
post_data = [];
pre_file_indices = [];
post_file_indices = [];
for i=1:length(patient_dir)
    patient_name = patient_dir(i).name;
    if ~isequal(patient_name, '.') && ~isequal(patient_name, '..') && ~isequal(patient_name, '.DS_Store')
        patient_folder = fullfile(audio_dir, patient_name);
        patient_file = dir(patient_folder);
        for j = 1:length(patient_file)
            csv_name = patient_file(j).name;
            if ~isequal(csv_name, '.') && ~isequal(csv_name, '..') && ~isequal(csv_name, '.DS_Store')
                if contains(csv_name, 'pre_VRP')
                    pre_files = [pre_files; fullfile(patient_folder, csv_name)];
                elseif contains(csv_name, 'pos_VRP')
                    post_files = [post_files; fullfile(patient_folder, csv_name)];
                end
            end
        end
    end
end

for i = 1:size(pre_files, 1)
    pre_file = pre_files(i, :);
    post_file = post_files(i, :);
    [~, pre_vrp] = FonaDynLoadVRP(pre_file);
    [~, post_vrp] = FonaDynLoadVRP(post_file);
    pre_file_index = size(pre_vrp, 1);
    post_file_index = size(post_vrp, 1);
    pre_file_indices = [pre_file_indices, pre_file_index];
    post_file_indices = [post_file_indices, post_file_index];
    pre_data = [pre_data; pre_vrp];
    post_data = [post_data; post_vrp];
end

%% Like a whole, don't separate pre and post.


%% separate pre and post
pre_data(:, [4, 11:end]) = [];
post_data(:, [4, 11:end]) = [];

[metricsName, pre_metrics, subplotNames] = decideMetrics(pre_data, 'vrp');
[metricsName, post_metrics, subplotNames] = decideMetrics(post_data, 'vrp');


vrp_mat = [];
cluster_index = [];
centroid_excel = {};

for k=2:6

% [idx, C_original, trained_data, cluster_names] = KmeansTraining(pre_metrics, k, pre_data);
[idx, C_original, trained_data, cluster_names] = KmeansTraining(post_metrics, k, post_data);

names = ['MIDI','dB','Total', 'Crest','SpecBal','CPPs','Entropy','dEGGmax',...
    'Qcontact','maxCluster', string(cluster_names)];
centroids = C_original;
Crest_min = 1.414;
Crest_max = 4;
SpecBal_min = -42;
SpecBal_max = -10;
CPPs_min = 3;
CPPs_max = 15;
Entropy_min = 0;
Entropy_max = 8;
dEGGmax_min = 1;
dEGGmax_max = 10;
Qcontact_min = 0.2;
Qcontact_max = 0.6;

centroids(:,1) = (centroids(:,1) -Crest_min) / (Crest_max - Crest_min);
centroids(:,2) = (centroids(:,2) -SpecBal_min) / (SpecBal_max - SpecBal_min);
centroids(:,3) = (centroids(:,3) -CPPs_min) / (CPPs_max - CPPs_min);
centroids(:,4) = (centroids(:,4) -Entropy_min) / (Entropy_max - Entropy_min);
centroids(:,5) = (centroids(:,5) -dEGGmax_min) / (dEGGmax_max - dEGGmax_min);
centroids(:,6) = (centroids(:,6) -Qcontact_min) / (Qcontact_max - Qcontact_min);

centroids = [centroids, centroids(:,1)];
% [vrp_mat, cluster_index] = log2vrp(indices, log_metrics);

start_point = 0;
for j=1:length(post_file_indices)
    f = figure;
    % dir contains ., .., DS_Store directories, so +3
    patient_name = post_files(j, 28:36);
    f.Position = [10 10 800 1800];
    tiledlayout(4,2, 'Padding', 'none', 'TileSpacing', 'compact');
    log_range = trained_data(start_point+1 : start_point+post_file_indices(j),:);
    log_range = fakeCyle(log_range, k);
%     my_field = [file_dir(j+sysFolderN).name, '_',char(string(k))];
%     variable.(my_field) = log_range;
    for s = 1:8
        if s == 2
            theta = ((0:1:6)/6)*2*pi;
            angles = 0:60:360;
            marks = ['o';'*';'+';'^';'x';'d';'.'; '_'; '^';'v';'o'];         
            rMax = max(max(centroids));
            colors = getColorFriendly(size(centroids, 1)); 
            subplot(4,2,2);
            labels = {'Crest'; 'SB'; 'CPP'; 'CSE'; 'Q_{\Delta}'; 'Q_{ci}'};
%             labels = {'Crest', 'SpecBal', 'CPPs'};
%             for L = 1:size(labels)
%                 labels{L} = join([string(labels(L)) ':' roundn(min(C_original(:, L)), -2) '~' roundn(max(C_original(:, L)), -2)], '');
%             end
            for L = 1:size(labels)
                labels{L} = join([string(labels(L))], '');
            end
        %     pax = polaraxes; 
        %     polaraxes(pax); 
            for i = 1 : size(centroids, 1)
                polarplot(theta, centroids(i,:), 'LineWidth', 2, 'Color', colors(i,:), 'Marker', marks(i));  
                ax = gca;
                ax.ThetaTick = angles;
                ax.ThetaTickLabel = labels;
                hold on
            end
            rlim([0 1]);
            title 'Centroid Polar in Percentage'
        else
            
            mSymbol = FonaDynPlotVRP(log_range, names, string(subplotNames(s)), subplot(4,2,s), 'ColorBar', 'on','PlotHz', 'off', 'MinCycles', 1);  
            pbaspect([1.5 1 1]);
            xlabel('midi');
            ylabel('dB');
            grid on
            if isequal(string(subplotNames(s)) ,'maxCluster')
                subtitle('Phonation Clusters');
            else
                subtitle(string(subplotNames(s)));
            end
        end
    end
    start_point = start_point + post_file_indices(j);

%     vrp_dir = fullfile(new_vrp_dir, patient_name);
%     if ~exist(vrp_dir, 'dir')
%         mkdir (vrp_dir)
%     end
    vrp_name = join([patient_name, '_classification_k=', string(k), '_VRP.csv'], '');
    vrp_file = fullfile(new_vrp_dir, vrp_name);
    FonaDynSaveVRP(vrp_file, names, log_range);
    
    sgtitle(patient_name);
    
    % save as pdfs
    pdf_name = join([patient_name, '_vrp_k=', string(k)],'');
    pdf_file = fullfile(new_pdf_dir, pdf_name);set(gcf,'PaperOrientation','portrait');
    set(gcf, 'PaperSize', [30, 40]);
    print(gcf, pdf_file,'-dpdf','-r600', '-bestfit');
%     print(gcf, pdf_file_separate,'-dpdf','-r600', '-bestfit');
    close gcf;
end



centroid_excel = [centroid_excel;size(C_original,1)];
for c = 1:size(C_original,1)
    centroid_excel = [centroid_excel; C_original(c,:)];
end
% centroid_file = join([main_folder, '\centroids.csv'], '');
% writecell(centroid_excel, centroid_file);
end

function [data, indices] = extractData(DIR, type, varargin)
    %type = 'vrp' or 'log'
    global sysFolderN
    file_indices = [];
    csv_data = [];
    log_indices = [];
    log_data = [];

    for i = 1:length(DIR)
        % Remove system folders.
        if(isequal(DIR(i).name,'.')||... 
           isequal(DIR(i).name,'..')||...
           isequal(DIR(i).name,'.DS_Store')||...
           ~DIR(i).isdir)
            sysFolderN = sysFolderN +1;
        end

        s = [DIR(1).folder '/' DIR(i).name '/']; 
        Folders = dir(s);
        n = 0;
            switch type
                case 'vrp'
                for iCount = 1:length(Folders)
                    % decide to use csv or log, in this case, use full_raw_VRP.csv
                    if endsWith(Folders(iCount).name, 'csv') && contains(Folders(iCount).name,'full') 
                        file_name = string(Folders(iCount).name);
                        file_path = join([s, file_name],'');
                        [~,vrp_array] = FonaDynLoadVRP(file_path);
                        %delete extreme values
%                         vrp_array = rmoutliers(vrp_array, 'mean');
                        file_index = size(vrp_array,1);
                        file_indices = [file_indices, file_index];
                        csv_data = [csv_data; vrp_array];
                    end
                end
                data = csv_data;
                indices = file_indices;

                case 'log'
                for iCount = 1:length(Folders)
                    if endsWith(Folders(iCount).name, 'aiff') && contains(Folders(iCount).name,'VRP')
                        file_name = string(Folders(iCount).name);
                        file_path = join([s, file_name],'');
                        % can add varargin here, to detect if FD is needed.
                        [logPlus] = FonaDyn230AugmentLogFile(file_path, 0);
                        %delete extreme values
                        logPlus = rmoutliers(logPlus, 'mean');
                        %如果一个文件里面有两个，把data和index合并
                        log_index = size(logPlus,1);
                        log_indices = [log_indices, log_index];
                        log_data = [log_data; logPlus];
                        if n > 0
                            log_indices(i-sysFolderN) = sum(log_indices(i-sysFolderN:end));
                            log_indices(i-sysFolderN + 1) = [];
                        end
                        n = n+1;
                    end
                end
                data = log_data;
                indices = log_indices;
            end
    end
end

function [metricsName, metricsRep, subplotNames] = decideMetrics(data, type)
    switch type
        case 'log'
            metricsName = {'Crest'; 'SB';'CPP';'CSE';'Qd';'Qc';'Clustering'};
            metricsRep = data(:,[5 6 7 9 11 12]);
            subplotNames = {'maxCluster'; 'polar'; 'Crest';'Qcontact'; 'SpecBal';'dEGGmax'; 'CPPs';'Entropy';};
        case 'vrp'
            metricsName = {'Crest'; 'SB';'CPP';'CSE';'Qd';'Qc';'Clustering'};
%             metricsName = {'Crest'; 'SB';'CPP';'Clustering'};
            metricsRep = data(:,(4:9));
%             metricsRep = data(:,(4:6));
            subplotNames = {'maxCluster'; 'polar'; 'Crest';'Qcontact'; 'SpecBal';'dEGGmax'; 'CPPs';'Entropy';};
%             subplotNames = {'maxCluster'; 'polar'; 'Crest'; 'SpecBal'; 'CPPs'};
    end
end

function [idx, C_original, trained_data, cluster_names] = KmeansTraining(metricsRep, k, data)
    %k=Integer or Array, if k = range(Array), training by different ks, then save as different filename
    % log for degg
    metricsRep(:,5) = log10(metricsRep(:,5));
    [metricsStd, PS] = mapminmax(metricsRep',0,1);
    metricsStd = metricsStd';
    [metricsStd, metricsM, metricsDev] = zscore(metricsStd);
    cluster_names = [];

    [idx, C] = kmeans(metricsStd, k, 'Display','final','OnlinePhase', 'on','Replicates', 10, 'MaxIter',100000);
    
    marks = ['bo';'r*';'m+';'g^';'yx'; 'k.'; 'w_'; 'c|' ; 'bs'; 'rd'; ];
    [trained_data, Dic] = setClustersPos(data, idx, k);
    
    for kk =1:k
        cluster_name =join(['Cluster ', string(kk)], '');
        cluster_names = [cluster_names, cluster_name];
    end
    C_original = C .* metricsDev + metricsM;
    C_original = mapminmax('reverse', C_original',PS);
    C_original = C_original';
    C_original(:,5) = 10 .^(C_original(:,5));
    C_original = C_original(Dic, :);
end

function [log_range] = fakeCyle(log_range,k)
    log_range(:, (end+1:end+k)) = zeros(size(log_range,1), k);
    for i = 1:k
        idx = find(log_range(:, 10) == i);
        log_range(idx, 10+i) = log_range(idx, 3);
    end
end

function [vrp_mat, start_point, cluster_index] = log2vrp(indices, log_metrics)
    start_point = 0;
    for j=1:length(indices)
        log_range = log_metrics(start_point+1 : start_point+indices(j),:);
        log_range(:,2:3) = round(log_range(:,2:3));
        midi = unique(log_range(:,2));
        spl = unique(log_range(:,3));
        sizeStart = size(vrp_mat,1);
        for n = 1:length(spl)
            for m = 1:length(midi)        
                a = find(log_range(:,2) == midi(m) & log_range(:,3) == spl(n));
                cluster_m = zeros(1,10+k);
                
                if ~isempty(a)
                    cluster_m(1) = midi(m);
                    cluster_m(2) = spl(n);
                    for p = 1:length(a)
                        index = log_range(a(p),35)+10;
                        cluster_m(index) = cluster_m(index) + 1;
                    end
                    cluster_m(4:9) = mean(log_range(a,[5 6 7 9 11 12]));
                    %10+k represents 10th slot in vrp file, and following k
                    %clusters.
                    maxCluster = find((cluster_m(11:10+k) == max(cluster_m(11:10+k))));
                    pos = randi(length(maxCluster));
                    cluster_m(10) = maxCluster(pos);
                    cluster_m(3) = sum(cluster_m(11:10+k));
                    vrp_mat = [vrp_mat; cluster_m];
                end
            end
        end
        sizeEnd = size(vrp_mat,1);
        cluster_index = [cluster_index, sizeEnd-sizeStart];
        start_point = start_point + indices(j);
    end
end


%set clusters color by the vertical position, so bottom cluster is always No.1
function [trained, Dic] = setClustersPos(data, idx, k)
    meanValue = [];
    trained = data;
    trained(:, end+1) = zeros(size(trained,1), 1);
    for i = 1:k
        meanValue(i) = mean(data(idx == i, 2));
    end
    [order, Dic] = sort(meanValue);
    for ii = 1:k
        for j = 1:k
            if meanValue(j) == order(ii)
                trained(idx==j, end) = ii;
            end
        end
    end
%     meanSPL = [];
%     meanF0 = [];
%     trained = data;
%     for i = 1:k
%         meanSPL(i) = mean(data(idx == i, 2));
%         meanF0(i) = mean(data(idx == i,1));
%     end
%     [order1, Dic1] = sort(meanSPL);
%     [order2, Dic2] = sort(meanF0);
%     meansquare = Dic1 .* Dic2;
%     [order, Dic] = sort(meansquare);
%     for ii = 1:k
%         for j = 1:k
%             if meansquare(j) == order(ii)
%                 trained(idx==j, 10) = ii;
%             end
%         end
%     end
end


function [axisl, axisb, axisw, axish] = getSubplotWH(n, ncols, nrows)
    axisw = (1 / ncols) * 0.95;
    axish = (1 / nrows) * 0.9;
    row = floor(n /(ncols+1) ) +1;
    col = mod(n-1, ncols) +1;
    axisl = (axisw+0.02) * (col - 1);
    axisb = (axish+0.02) * (row-1);
end

function C_original = perecentage_polar(data,C_original)
    Crest_min = min(data(:,4));
    Crest_max = max(data(:,4));
    SpecBal_min = min(data(:,5));
    SpecBal_max = max(data(:,5));
    CPPs_min = min(data(:,6));
    CPPs_max = max(data(:,6));
    Entropy_min = min(data(:,7));
    Entropy_max = max(data(:,7));
    dEGGmax_min = min(data(:,8));
    dEGGmax_max = max(data(:,8));
    Qcontact_min = min(data(:,9));
    Qcontact_max = max(data(:,9));
    
    C_original(:,1) = C_original(:,1) / (Crest_max - Crest_min);
    C_original(:,2) = C_original(:,2) / (SpecBal_max - SpecBal_min);
    C_original(:,3) = C_original(:,3) / (CPPs_max - CPPs_min);
    C_original(:,4) = C_original(:,4) / (Entropy_max - Entropy_min);
    C_original(:,5) = C_original(:,5) / (dEGGmax_max - dEGGmax_min);
    C_original(:,6) = C_original(:,6) / (Qcontact_max - Qcontact_min);
end

