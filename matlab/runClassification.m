%% K-means training on six metrics
clear all; close all;
% initialize the centroids
init_centroids =[0.5, 0.2, 0.2, 0.8, 0.3,    0.5; %pre-contacting
                 0.5, 0.1, 0.2, 1,   0.5,    0.3; %transition
                 0.5, 0.2, 0.5, 0.3, 0.8,    0.4; %loose
                 0.5, 0.5, 0.1, 0.8, 0.8,    0.5; %firm
                 0.5, 0.8, 0.1, 0.8, 1.1,    0.6];%hard

% scatter plot the vrp metrics
% In order to run this, % the <metricsName> and <metricsRep> need to be stored during function KmeansTraining
% metricsName = {'Crest'; 'specbal';'CPPs';'CSE';'Qd';'Qc';'Clustering'};
% metricsRep = csv_data(:,5:10);
% %resize Crest
% metricsRep(:,1) = metricsRep(:,1) / 10.0;
% %resize SB
% metricsRep(:,1) = metricsRep(:,2) / 40.0 + 1;
% %resize CPPs
% metricsRep(:,2) = metricsRep(:,3) / 20.0;
% %resize CSE
% metricsRep(:,3) = metricsRep(:,4) / 10.0;
% %resize Qdelta
% metricsRep(:,4) = log10(max(metricsRep(:,5), 1));
% data = audioread(log_dir, 'native');
% [~,ax] = plotmatrix(metrics_T); plot scatter matrix
% for i=1:length(metricsName)
%     ylabel(ax(i,1),metricsName(i));
%     xlabel(ax(8,i),metricsName(i));
% end
% title('Scatter Matrix');

% prepare the data
type = {'Male'; 'Female'; 'Children'; 'All'};   % iterate the folder names
for t = 4 : length(type)
KinderEGG_dir = string(join(['L:\Huanchen\KinderEGG\data\',type(t)],''));
pdf_dir = string(join(['L:\Huanchen\KinderEGG\Generated from VRP\',type(t),'\Clustering plot'], ''));
recreated_vrp = string(join(['L:\Huanchen\KinderEGG\Generated from VRP\',type(t),'\recreated_vrp'], ''));
main_folder = string(join(['L:\Huanchen\KinderEGG\Generated from VRP\',type(t)], ''));

file_dir = dir(KinderEGG_dir);
global sysFolderN 
sysFolderN = 0;
[data, indices] = extractData(file_dir, 'log'); % save the file 'vrp' or 'log' into <data>
data(:, [4, 11:end]) = [];
[metricsName, metricsRep, subplotNames] = decideMetrics(data, 'log');


vrp_mat = [];
cluster_index = [];
centroid_excel = {};

% count the lengths of each file, save them as a array log_start
% log_start = 1;
% for ind = 1:length(indices)
%     new_log = log_metrics(log_start:indices(ind), :);
%     new_log_name = [file_dir(ind+sysFolderN).name, '_class_log.csv'];
%     new_log_dir = fullfile(KinderEGG_dir, file_dir(ind+sysFolderN).name, new_log_name);
%     writematrix(new_log, new_log_dir);
%     log_start = log_start + indices(ind);
% end


% K-means training starts from here
for k=2:10

[idx, C_original, trained_data, cluster_names] = KmeansTraining(metricsRep, k, data);
names = ['MIDI','dB','Total', 'Crest','SpecBal','CPPs','Entropy','dEGGmax',...
    'Qcontact','maxCluster', string(cluster_names)];
% [vrp_mat, cluster_index] = log2vrp(indices, log_metrics);

start_point = 0;
for j=1:length(indices)
    f = figure;
    f.Position = [10 10 800 1800];
    tiledlayout(4,2, 'Padding', 'none', 'TileSpacing', 'compact');
    log_range = trained_data(start_point+1 : start_point+indices(j),:);
    log_range = fakeCyle(log_range, k);
    for s = 1:8
        if s == 2
            theta = ((0:1:6)/6)*2*pi;
            angles = 0:60:360;
            marks = ['o';'*';'+';'^';'x';'d';'.'; '_'; '^';'v';'o'];
            centroids = C_original;
            %find value max in original data\

            for c = 1:size(centroids,2)
                colomnMax = max(centroids(:,c));
                colomnMin = min(centroids(:,c));
                centroids(:,c) = (centroids(:,c)-colomnMin)./(colomnMax-colomnMin);
            end
            centroids = [centroids, centroids(:,1)];
            rMax = max(max(centroids));
            colors = getColorFriendly(size(centroids, 1)); 
            subplot(4,2,2);
            labels = {'Crest'; 'SB'; 'CPP'; 'CSE'; 'Q_{\Delta}'; 'Q_{ci}'};
%             labels = {'Crest', 'SpecBal', 'CPPs'};
            for L = 1:size(labels)
                labels{L} = join([string(labels(L)) ':' roundn(min(C_original(:, L)), -2) '~' roundn(max(C_original(:, L)), -2)], '');
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
            rlim([-0.1 rMax]);
            title 'Centroid Polar'
        else
            mSymbol = FonaDynPlotVRP(log_range, names, string(subplotNames(s)), subplot(4,2,s), 'ColorBar', 'on','PlotHz', 'on', 'MinCycles', 5);  
            pbaspect([1.5 1 1]);
            xlabel('Hz');
            ylabel('dB');
            grid on
            if isequal(string(subplotNames(s)) ,'maxCluster')
                subtitle('Phonation Clusters');
            else
                subtitle(string(subplotNames(s)));
            end
        end
    end
    
    vrp_dir = fullfile(recreated_vrp, file_dir(j+sysFolderN).name);
    if ~exist(vrp_dir, 'dir')
        mkdir (vrp_dir)
    end
    vrp_file = join([vrp_dir, '\', file_dir(j+sysFolderN).name, '-classification-k=', string(k), '_VRP.csv'], '');
    FonaDynSaveVRP(vrp_file, names, log_range);
    centroid_excel{(2*k-1)} = string(k); 
    centroid_excel{2*k} = C_original;
    
    sgtitle(file_dir(j+sysFolderN).name);
    start_point = start_point + indices(j);
    
    % save as pdfs
    pdf_file = join([pdf_dir, '\',file_dir(j+sysFolderN).name, '-vrp-k=', string(k)],'');
    pdf_dir_s = join([subject_vrp,'\',file_dir(j+sysFolderN).name], '');
    if ~exist(pdf_dir_s, 'dir')
        mkdir(pdf_dir_s)
    end
    pdf_file_s = join([pdf_dir_s, '\',file_dir(j+sysFolderN).name, '_vrp_k=', string(k)],'');
%     set(gcf,'PaperPositionMode','Auto'); 
%     set(gcf,'PaperPosition',[4.65,-2.32,20.38,25.65]);
    set(gcf,'PaperOrientation','portrait');
    set(gcf, 'PaperSize', [30, 40]);
    print(gcf, pdf_file,'-dpdf','-r600', '-bestfit');
    print(gcf, pdf_file_s,'-dpdf','-r600', '-bestfit');
    close gcf;
end


end
centroid_file = [main_folder, '\centroids.txt'];
writematrix(centroid_excel, centroid_file);
end

%% plot the Union vrp v.1
% create plots of 'Union' map
mean_vrp = zeros(15000,15);
for x = 1:100
    for y = 1:150
        pair = find(vrp_mat(:,1) == x & vrp_mat(:,2) == y);
        if ~isempty(pair)
            mean_vrp(n, 1:2) = [x,y];
            mean_vrp(n, 3) = sum(vrp_mat(pair, 11:15), 'all');
            mean_vrp(n, 4:9) = mean(vrp_mat(pair, 4:9), 1);
            mean_vrp(n, 11:end) = sum(vrp_mat(pair, 11:15), 1);
            mean_vrp(n, 10) = find(mean_vrp(n, 11:end) == max(mean_vrp(n, 11:end)),1);
            n = n+1;
        end
    end
end
mean_vrp(all(mean_vrp==0,2),:)=[];
names = {'MIDI','dB','Total', 'Crest','SpecBal','CPPs','Entropy','dEGGmax',...
    'Qcontact','maxCluster','Cluster 1','Cluster 2','Cluster 3','Cluster 4','Cluster 5'};
mSymbol = FonaDynPlotVRP(mean_vrp, names, 'maxCluster', figure, 'Range', [29, 90, 28, 120], 'ColorBar', 'on','PlotHz', 'on');  
%     title(text);
xlabel('Hz');
ylabel('dB');
grid on
subtitle('Average VRP');

% save as pdfs
pdf_file = join([pdf_dir, '/','AverageVRP']);
print(gcf, pdf_file,'-dpdf','-r600');
close gcf;    


%% plot the Union vrp  v.2
clear all; close all;
% kmeans++ clustering for kinderEGG

type = {'Male'; 'Female'; 'Children';'All'};
for t = 1 : length(type)
KinderEGG_dir = string(join(['E:\Classification\data\',type(t)],''));
pdf_dir = string(join(['E:\Classification\Generated from VRP\',type(t),'\Cluster by subject'], ''));
pdf_dir_k = string(join(['E:\Classification\Generated from VRP\',type(t),'\Cluster'], ''));
recreated_vrp = string(join(['E:\Classification\Generated from VRP\',type(t),'\recreated_vrp'], ''));
main_folder = string(join(['E:\Classification\Generated from VRP\',type(t)], ''));

file_dir = dir(KinderEGG_dir);
global sysFolderN 
sysFolderN = 0;
[data, indices] = extractData(file_dir, 'vrp');
data(:, [4, 11:end]) = [];
[metricsName, metricsRep, subplotNames] = decideMetrics(data, 'vrp');
vrp_mat = [];
cluster_index = [];
centroid_excel = {};
for k=2:6

    [idx, C_original, trained_data, cluster_names] = KmeansTraining(metricsRep, k, data);
    names = ['MIDI','dB','Total', 'Crest','SpecBal','CPPs','Entropy','dEGGmax',...
        'Qcontact','maxCluster', string(cluster_names)];
    
    trained_data = combineVRP(trained_data, k);
    
%     trained_data = fakeCyle(trained_data, k);
    mSymbol = FonaDynPlotVRP(trained_data, names, 'maxCluster', subplot(4,2,k-1), 'ColorBar', 'on','PlotHz', 'off', 'MinCycles', 5);
    subtitle(['k=', char(string(k))]);
    pbaspect([1.5 1 1]);
    xlabel('midi');
    ylabel('dB');
    grid on
end
% save as pdfs
pdf_file = join([main_folder, '\Union',char(type(t))], '');
set(gcf,'PaperOrientation','portrait');
set(gcf, 'PaperSize', [30, 40]);
print(gcf, pdf_file,'-dpdf','-r600', '-bestfit');
close gcf;
end




%% K-means training on the log files and plot as vrp
clear all; close all;
% kmeans++ clustering for kinderEGG

type = {'Male'; 'Female'; 'Children'; 'All'};
for t = 4 : length(type)
KinderEGG_dir = string(join(['E:\Classification\data\',type(t)],''));
% KinderEGG_dir = 'L:\fonadyn\Huanchen\KinderEGG\data\test\Male';
pdf_dir = string(join(['L:\fonadyn\Huanchen\KinderEGG\Generated from Logfile(base)\',type(t),'\Clustering plot'], ''));
recreated_vrp = string(join(['E:\Classification\Generated from Logfile(base)\',type(t),'\recreated_vrp'], ''));
recreated_log = string(join(['L:\fonadyn\Huanchen\KinderEGG\Generated from Logfile(base)\',type(t),'\recreated_log'], ''));
subject_vrp = string(join(['L:\fonadyn\Huanchen\KinderEGG\Generated from Logfile(base)\',type(t),'\Clustering by subject'], ''));
main_folder = string(join(['L:\fonadyn\Huanchen\KinderEGG\Generated from Logfile(base)\',type(t)], ''));
% 
file_dir = dir(KinderEGG_dir);
global sysFolderN 
sysFolderN = 0;
[data, indices] = extractData(file_dir, 'log');
% data(:, [4, 11:end]) = [];
[metricsName, metricsRep, subplotNames] = decideMetrics(data, 'log');
vrp_mat = [];
cluster_index = [];
centroid_excel = [];


for k=2:6
[idx, C_original, trained_data, cluster_names] = KmeansTraining(metricsRep, k, data);
names = ['MIDI','dB','Total', 'Crest','SpecBal','CPPs','Entropy','dEGGmax',...
    'Qcontact','maxCluster', string(cluster_names)];

% log_start = 1;
% for ind = 1:length(indices)
%     new_log = trained_data(log_start:indices(ind), :);
%     new_log_name = [file_dir(ind+sysFolderN).name, '_classification_VRP_Log.aiff'];
%     new_log_dir = fullfile(KinderEGG_dir, file_dir(ind+sysFolderN).name, new_log_name);
%     audiowrite(new_log_dir, new_log, 44100);
%     log_start = log_start + indices(ind);
% end
start = 1;
data = trained_data;
data(:,8) = trained_data(:,35);
data(:,35) = [];
    for ind = 1:length(indices)
        [names, dataArray, vrpArray] = FonaDynArraysLogFileToVRP(data(start:start+indices(ind)-1, :), k);
        start = start + indices(ind);
        new_log_name = join([file_dir(ind+2).name, '_classification_k=', string(k),'_VRP.csv'], '');
        new_log_dir = fullfile(recreated_vrp, file_dir(ind+sysFolderN).name, new_log_name);
        FonaDynSaveVRP(new_log_dir, names, vrpArray)
    end
end
end

start_point = 0;
for j=1:length(cluster_index)
    f = figure;
    f.Position = [10 10 800 1800];
    tiledlayout(4,2, 'Padding', 'none', 'TileSpacing', 'compact');
    log_range = trained_data(start_point+1 : start_point+cluster_index(j),:);
%     log_range = fakeCyle(log_range, k);
    for s = 1:8
        if s == 2
            theta = ((0:1:6)/6)*2*pi;
            angles = 0:60:360;
            marks = ['o';'*';'+';'^';'x';'d';'.'; '_'; '^';'v';'o'];
            centroids = C_original;
            %find value max in original data\

            for c = 1:size(centroids,2)
                colomnMax = max(centroids(:,c));
                colomnMin = min(centroids(:,c));
                centroids(:,c) = (centroids(:,c)-colomnMin)./(colomnMax-colomnMin);
            end
            centroids = [centroids, centroids(:,1)];
            rMax = max(max(centroids));
            colors = getColorFriendly(size(centroids, 1)); 
            subplot(4,2,2);
            labels = {'Crest'; 'SB'; 'CPP'; 'CSE'; 'Q_{\Delta}'; 'Q_{ci}'};
%             labels = {'CSE'; 'Q_{\Delta}'; 'Q_{ci}'};
            for L = 1:size(labels)
                labels{L} = join([string(labels(L)) ':' roundn(min(C_original(:, L)), -2) '~' roundn(max(C_original(:, L)), -2)], '');
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
            rlim([-0.1 rMax]);
            title 'Centroid Polar'
        else
            mSymbol = FonaDynPlotVRP(log_range, names, string(subplotNames(s)), subplot(4,2,s), 'ColorBar', 'on','PlotHz', 'on', 'MinCycles', 5);  
            pbaspect([1.5 1 1]);
            xlabel('Hz');
            ylabel('dB');
            grid on
            if isequal(string(subplotNames(s)) ,'maxCluster')
                subtitle('Phonation Clusters');
            else
                subtitle(string(subplotNames(s)));
            end
        end
    end
    
    vrp_dir = fullfile(recreated_vrp, file_dir(j+sysFolderN).name);
    if ~exist(vrp_dir, 'dir')
        mkdir (vrp_dir)
    end
    vrp_file = join([vrp_dir, '\', file_dir(j+sysFolderN).name, '_classification_k=', string(k), '_VRP.csv'], '');
    FonaDynSaveVRP(vrp_file, names, log_range);
       
    sgtitle(file_dir(j+sysFolderN).name);
    start_point = start_point + cluster_index(j);
    
    % save as pdfs
    pdf_file = join([pdf_dir, '\',file_dir(j+sysFolderN).name, '_vrp_k=', string(k)],'');
    pdf_dir_s = join([subject_vrp,'\',file_dir(j+sysFolderN).name], '');
    if ~exist(pdf_dir_s, 'dir')
        mkdir(pdf_dir_s)
    end
    pdf_file_s = join([pdf_dir_s, '\',file_dir(j+sysFolderN).name, '_vrp_k=', string(k)],'');
%     set(gcf,'PaperPositionMode','Auto'); 
%     set(gcf,'PaperPosition',[4.65,-2.32,20.38,25.65]);
    set(gcf,'PaperOrientation','portrait');
    set(gcf, 'PaperSize', [30, 40]);
    print(gcf, pdf_file,'-dpdf','-r600', '-bestfit');
    print(gcf, pdf_file_s,'-dpdf','-r600', '-bestfit');
    close gcf;
end
centroid_excel = [centroid_excel; C_original; nan, nan, nan, nan,nan,nan];

centroid_file = join([main_folder, '\centroids.csv'], '');
writematrix(centroid_excel, centroid_file);


%% compare the log results to the vrp results
subject = [];
accuracy = [];
for k = 2:6
    log_dir = 'E:\Classification\Generated from Logfile(base)\Male\recreated_vrp\';
    vrp_dir = 'E:\Classification\generated from VRP\Male\recreated_vrp\';
    vrp_folder = dir(vrp_dir);
    for i = 1:length(vrp_folder)
        % Remove system folders.
        if(isequal(vrp_folder(i).name,'.')||... 
           isequal(vrp_folder(i).name,'..')||...
           ~vrp_folder(i).isdir)
        continue
        end
        subject_name = vrp_folder(i).name;
        log_2_dir = fullfile(log_dir,subject_name);
        vrp_2_dir = fullfile(vrp_dir,subject_name);
        k_string = ['k=',char(string((k)))];
        log_2_folder = dir(log_2_dir);
        vrp_2_folder = dir(vrp_2_dir);
        subject = [subject; [subject_name, '_',char(string(k))]];
        for c = 1:length(log_2_folder)
            if contains(log_2_folder(c).name, k_string)
                [~, vrpArray_log] = FonaDynLoadVRP(fullfile(log_2_dir,log_2_folder(c).name));
            end
        end
        [vrpArray_log, ~] = setClustersPos(vrpArray_log, vrpArray_log(:,11), k);
        for c = 1:length(vrp_2_folder)
            if contains(vrp_2_folder(c).name, k_string)
                [~, vrpArray_vrp] = FonaDynLoadVRP(fullfile(vrp_2_dir,vrp_2_folder(c).name));
            end
        end
        [vrpArray_vrp, ~] = setClustersPos_copy(vrpArray_vrp, vrpArray_vrp(:,10), k);
        accuracy_count = 0;
        [a,b,c] = intersect(vrpArray_log(:,1:2), vrpArray_vrp(:,1:2),'rows');
        for j = 1:length(b)
            if vrpArray_log(b(j),11) == vrpArray_vrp(c(j), 10)
                accuracy_count = accuracy_count+1;
            end
        end
        accuracy = [accuracy; accuracy_count / size(a,1)];
    end
end


%% K-means training on vrp with chosen group of metrics v.1
clear all; close all;
% kmeans++ clustering for kinderEGG

type = {'Male'; 'Female'; 'Children'; 'All'};
for t = 3 : length(type)
KinderEGG_dir = string(join(['F:\Classification\data\',type(t)],''));
% KinderEGG_dir = 'C:\Users\admin\Desktop\Classification\data\Male';
pdf_dir = string(join(['F:\Classification\Generated from Logfile(base)\',type(t),'\Clustering plot'], ''));
recreated_vrp = string(join(['F:\Classification\Generated from Logfile(base)\',type(t),'\recreated_vrp'], ''));
recreated_log = string(join(['F:\Classification\Generated from Logfile(base)\',type(t),'\recreated_log'], ''));
subject_vrp = string(join(['F:\Classification\Generated from Logfile(base)\',type(t),'\Clustering by subject'], ''));
main_folder = string(join(['F:\Classification\Generated from Logfile(base)\',type(t)], ''));
% 
file_dir = dir(KinderEGG_dir);
global sysFolderN 
sysFolderN = 0;
[data, indices] = extractData(file_dir, 'log');
% data(:, [4, 11:end]) = [];

[metricsName, metricsRep, subplotNames] = decideMetrics(data, 'log');

vrp_mat = [];
cluster_index = [];
centroid_excel = [];

for k=2:6
[idx, C_original, trained_data, cluster_names] = KmeansTraining(metricsRep, k, data);
names = ['MIDI','dB','Total', 'Crest','SpecBal','CPPs','Entropy','dEGGmax',...
    'Qcontact','maxCluster', string(cluster_names)];

log_start = 1;
for ind = 1:length(indices)
    new_log = trained_data(log_start:indices(ind)+log_start-1, :);
    new_log(:, 8) = new_log(:, 35)-1;
    new_log(:, 35) = [];
    new_log_name = join([file_dir(ind+sysFolderN).name, '_k=',string(k),'_Log.aiff'],'');
    new_log_dir = fullfile(recreated_log, file_dir(ind+sysFolderN).name);
    if ~isfolder(new_log_dir)
        mkdir(new_log_dir);
    end
    new_log_dir = fullfile(new_log_dir,new_log_name);
    aiffwrite(new_log_dir, new_log, 44100);

    [names, ~, log_range] = FonaDynArraysLogFileToVRP(new_log, k);
%     [trained_data, cluster_index] = log2vrp(indices, trained_data, k);

    f = figure;
    f.Position = [10 10 800 1800];
    tiledlayout(4,2, 'Padding', 'none', 'TileSpacing', 'compact');
    log_range = trained_data(start_point+1 : start_point+cluster_index(j),:);
    log_range = fakeCyle(log_range, k);
    for s = 1:8
        if s == 2
            theta = ((0:1:6)/6)*2*pi;
            angles = 0:60:360;
            marks = ['o';'*';'+';'^';'x';'d';'.'; '_'; '^';'v';'o'];
            centroids = C_original;
            %find value max in original data\

            for c = 1:size(centroids,2)
                colomnMax = max(centroids(:,c));
                colomnMin = min(centroids(:,c));
                centroids(:,c) = (centroids(:,c)-colomnMin)./(colomnMax-colomnMin);
            end
            centroids = [centroids, centroids(:,1)];
            rMax = max(max(centroids));
            colors = getColorFriendly(size(centroids, 1)); 
            subplot(4,2,2);
            labels = {'Crest'; 'SB'; 'CPP'; 'CSE'; 'Q_{\Delta}'; 'Q_{ci}'};
%             labels = {'CSE'; 'Q_{\Delta}'; 'Q_{ci}'};
            for L = 1:size(labels)
                labels{L} = join([string(labels(L)) ':' roundn(min(C_original(:, L)), -2) '~' roundn(max(C_original(:, L)), -2)], '');
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
            rlim([-0.1 rMax]);
            title 'Centroid Polar'
        else
            mSymbol = FonaDynPlotVRP(log_range, names, string(subplotNames(s)), subplot(4,2,s), 'ColorBar', 'on','PlotHz', 'on', 'MinCycles', 5);  
            pbaspect([1.5 1 1]);
            xlabel('Hz');
            ylabel('dB');
            grid on
            if isequal(string(subplotNames(s)) ,'maxCluster')
                subtitle('Phonation Clusters');
            else
                subtitle(string(subplotNames(s)));
            end
        end
    end
    
    vrp_dir = fullfile(recreated_vrp, file_dir(ind+sysFolderN).name);
    if ~exist(vrp_dir, 'dir')
        mkdir (vrp_dir)
    end
    
    
    vrp_file = join([vrp_dir, '\', file_dir(ind+sysFolderN).name, '_classification_k=', string(k), '_VRP.csv'], '');
    %save generated VRP
    FonaDynSaveVRP(vrp_file, names, log_range);
       
%     sgtitle(file_dir(ind+sysFolderN).name);
%     start_point = start_point + cluster_index(ind);
    
    pdf_file = join([pdf_dir, '\',file_dir(ind+sysFolderN).name, '_vrp_k=', string(k)],'');
    pdf_dir_s = join([subject_vrp,'\',file_dir(ind+sysFolderN).name], '');
    if ~exist(pdf_dir_s, 'dir')
        mkdir(pdf_dir_s)
    end
    pdf_file_s = join([pdf_dir_s, '\',file_dir(ind+sysFolderN).name, '_vrp_k=', string(k)],'');
%     set(gcf,'PaperOrientation','portrait');
%     set(gcf, 'PaperSize', [30, 40]);
%     
    
    % save pdf
%     print(gcf, pdf_file_s,'-dpdf','-r600', '-bestfit');
%     close gcf;
    log_start = log_start + indices(ind);
end
centroid_excel = [centroid_excel; C_original; nan, nan, nan, nan,nan,nan];
centroid_file = join([main_folder, '\centroids.csv'], '');
writematrix(centroid_excel, centroid_file);
end

end


%% K-means training on vrp with chosen group of metrics v.2
clear all; close all;
% kmeans++ clustering for kinderEGG

type = {'Male'; 'Female'; 'Children';'All'};                                                                                                                                  
for t = 4 : length(type)
KinderEGG_dir = string(join(['F:\Classification\data\',type(t)],''));
pdf_dir = string(join(['F:\Classification\Generated from VRP-EGG only\',type(t),'\Cluster by subject'], ''));
pdf_dir_k = string(join(['F:\Classification\Generated from VRP-EGG only\',type(t),'\Cluster'], ''));
recreated_vrp = string(join(['F:\Classification\Generated from VRP-EGG only\',type(t),'\recreated_vrp'], ''));
main_folder = string(join(['F:\Classification\Generated from VRP-EGG only\',type(t)], ''));
file_dir = dir(KinderEGG_dir);
global sysFolderN 
sysFolderN = 0;
[data, indices] = extractData(file_dir, 'vrp');
data(:, [4, 11:end]) = [];
[metricsName, metricsRep, subplotNames] = decideMetrics(data, 'vrp');
vrp_mat = [];
cluster_index = [];
centroid_excel = {};
% log_start = 1;
% for ind = 1:length(indices)
%     new_log = log_metrics(log_start:indices(ind), :);
%     new_log_name = [file_dir(ind+sysFolderN).name, '_class_log.csv'];
%     new_log_dir = fullfile(KinderEGG_dir, file_dir(ind+sysFolderN).name, new_log_name);
%     writematrix(new_log, new_log_dir);
%     log_start = log_start + indices(ind);
% end
for k=2:6
[idx, C_original, trained_data, cluster_names] = KmeansTraining(metricsRep, k, data);
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

% centroids(:,1) = (centroids(:,1) -Crest_min) / (Crest_max - Crest_min);
% centroids(:,2) = (centroids(:,2) -SpecBal_min) / (SpecBal_max - SpecBal_min);
% centroids(:,3) = (centroids(:,3) -CPPs_min) / (CPPs_max - CPPs_min);
centroids(:,1) = (centroids(:,1) -Entropy_min) / (Entropy_max - Entropy_min);
centroids(:,2) = (centroids(:,2) -dEGGmax_min) / (dEGGmax_max - dEGGmax_min);
centroids(:,3) = (centroids(:,3) -Qcontact_min) / (Qcontact_max - Qcontact_min);

centroids = [centroids, centroids(:,1)];
% [vrp_mat, cluster_index] = log2vrp(indices, log_metrics);

start_point = 0;
for j=1:length(indices)
    f = figure;
    f.Position = [10 10 800 1800];
    tiledlayout(4,2, 'Padding', 'none', 'TileSpacing', 'compact');
    log_range = trained_data(start_point+1 : start_point+indices(j),:);
    log_range = fakeCyle(log_range, k);
    my_field = [file_dir(j+sysFolderN).name, '_',char(string(k))];
    variable.(my_field) = log_range;
    for s = 1:5
        if s == 2
            theta = ((0:1:3)/3)*2*pi;
            angles = 0:120:360;
            marks = ['o';'*';'+';'^';'x';'d';'.'; '_'; '^';'v';'o'];
            
            %find value max in original data\

%             for c = 1:size(centroids,2)
%                 colomnMax = max(centroids(:,c));
%                 colomnMin = min(centroids(:,c));
%                 centroids(:,c) = (centroids(:,c)-colomnMin)./(colomnMax-colomnMin);
%             end
            
            rMax = max(max(centroids));
            colors = getColorFriendly(size(centroids, 1)); 
            subplot(4,2,2);
%             labels = {'Crest'; 'SB'; 'CPP'; 'CSE'; 'Q_{\Delta}'; 'Q_{ci}'};
            labels = {'CSE'; 'Q_{\Delta}'; 'Q_{ci}'};
%             for L = 1:size(labels)
%                 labels{L} = join([string(labels(L)) ':' roundn(min(C_original(:, L)), -2) '~' roundn(max(C_original(:, L)), -2)], '');
%             end
%             for L = 1:size(labels)
%                 labels{L} = join([string(labels(L))], '');
%             end
        %     pax = polaraxes; 
        %     polaraxes(pax); 
            for i = 1 : size(centroids, 1)
                polarplot(theta, centroids(i,:), 'LineWidth', 2, 'Color', colors(i,:), 'Marker', marks(i));  
                ax = gca;
                ax.ThetaTick = angles;
                ax.ThetaTickLabel = labels;
                hold on
            end
            rlim([0 rMax]);
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
    
    vrp_dir = fullfile(recreated_vrp, file_dir(j+sysFolderN).name);
    if ~exist(vrp_dir, 'dir')
        mkdir (vrp_dir)
    end
    vrp_file = join([vrp_dir, '\', file_dir(j+sysFolderN).name, '_classification_k=', string(k), '_VRP.csv'], '');
    FonaDynSaveVRP(vrp_file, names, log_range);
    
    sgtitle(file_dir(j+sysFolderN).name);
    start_point = start_point + indices(j);
    
    % save as pdfs
    pdf_file = join([pdf_dir_k,'\',file_dir(j+sysFolderN).name, '_vrp_k=', string(k)],'');
    pdf_dir_separate = join([pdf_dir,'\',file_dir(j+sysFolderN).name], '');
    if ~exist(pdf_dir_separate, 'dir')
        mkdir(pdf_dir_separate)
    end
    if ~exist(pdf_dir_k, 'dir')
        mkdir(pdf_dir_k)
    end
    pdf_file_separate = join([pdf_dir_separate, '\',file_dir(j+sysFolderN).name, '_vrp_k=', string(k)],'');
%     set(gcf,'PaperPositionMode','Auto'); 
%     set(gcf,'PaperPosition',[4.65,-2.32,20.38,25.65]);
    set(gcf,'PaperOrientation','portrait');
    set(gcf, 'PaperSize', [30, 40]);
    print(gcf, pdf_file,'-dpdf','-r600', '-bestfit');
    print(gcf, pdf_file_separate,'-dpdf','-r600', '-bestfit');
    close gcf;
end
centroid_excel = [centroid_excel;size(C_original,1)];
for c = 1:size(C_original,1)
    centroid_excel = [centroid_excel; C_original(c,:)];
end
end
centroid_file = join([main_folder, '\centroids.csv'], '');
writecell(centroid_excel, centroid_file);
end


%% test of polar plotting of cluster centroids, play around with the polar plots
% Here: six metrics and angles (Crest is set to 0.5)

theta = [((0:1:6)/6)*2*pi] ;
angles = 0:60:360;

% data = [ CPP, SB, Qci, CSE, Qdelta, Crest, CPP ];
centroids  = [ 0.23 0.27 0.48 0.43 0.38 0.50 0.23 ;
               0.18 0.39 0.48 0.49 0.82 0.50 0.18 ;
               0.38 0.33 0.40 0.10 0.70 0.50 0.38 ;
               0.29 0.67 0.46 0.38 0.41 0.50 0.29 ;
               0.50 0.62 0.43 0.05 0.82 0.50 0.50 ];

colors = colormapFD(size(centroids, 1), 0.7); 
figure
pax = polaraxes; 
polaraxes(pax); 
for i = 1 : size(centroids, 1)
    polarplot(theta, centroids(i,:), 'LineWidth', 2, 'Color', colors(i,:));  
    hold on
end
rlim(pax, [0 1]);
pax.ThetaTick = angles;
labels = { 'CPPs', 'SB', 'Q_{ci}', 'CSE', 'Q_{\Delta}', 'Crest' };
pax.ThetaTickLabel = labels;
title 'polarcentroids.m'


%% test of Kmeans training on gradients
clear all; close all;
% kmeans++ clustering for kinderEGG

type = {'Male'; 'Female'; 'Children'; 'All'};
for t = 1 : length(type)
KinderEGG_dir = string(join(['C:\Users\admin\Desktop\Classification\data\',type(t)],''));
% KinderEGG_dir = 'L:\fonadyn\Huanchen\KinderEGG\data\test\Male';
pdf_dir = string(join(['C:\Users\admin\Desktop\Classification\test',type(t),'\Clustering plot'], ''));
recreated_vrp = string(join(['C:\Users\admin\Desktop\Classification\test',type(t),'\recreated_vrp'], ''));
% recreated_log = string(join(['C:\Users\admin\Desktop\Classification\test',type(t),'\recreated_log'], ''));
subject_vrp = string(join(['C:\Users\admin\Desktop\Classification\test',type(t),'\Clustering by subject'], ''));
main_folder = string(join(['C:\Users\admin\Desktop\Classification\test',type(t)], ''));
% 
file_dir = dir(KinderEGG_dir);
global sysFolderN 
sysFolderN = 0;
[data, indices] = extractData(file_dir, 'vrp');
data(:, [4, 11:end]) = [];
Gx = data;
Gy = data;
start = 0;
for i = 1:length(indices)
    [Fx, Fy] = getGradient(data((start+1:start+indices(i)),:));
    Gx((start+1:start+indices(i)),[4 5 6 7 8 9]) = Fx;
    Gy((start+1:start+indices(i)),[4 5 6 7 8 9]) = Fy;
    start = start + indices(i);
end
[metricsName, metricsRep, subplotNames] = decideMetrics(Gx, 'vrp');
vrp_mat = [];
cluster_index = [];
centroid_excel = [];
for k=5:5
a = [metricsRep, Gx(:,4:9),Gy(:,4:9)];
[idx, C_original, trained_data, cluster_names] = KmeansTraining(a, k, Gx);
names = ['MIDI','dB','Total', 'Crest','SpecBal','CPPs','Entropy','dEGGmax',...
    'Qcontact','maxCluster', string(cluster_names)];
names = ['MIDI','dB','Total', 'Crest','SpecBal','CPPs','Entropy','dEGGmax',...
    'Qcontact','maxCluster', string(cluster_names)];
% log_start = 1;
% for ind = 1:length(indices)
%     new_log = trained_data(log_start:indices(ind), :);
%     new_log_name = [file_dir(ind+sysFolderN).name, '_classification_VRP_Log.aiff'];
%     new_log_dir = fullfile(KinderEGG_dir, file_dir(ind+sysFolderN).name, new_log_name);
%     audiowrite(new_log_dir, new_log, 44100);
%     log_start = log_start + indices(ind);
% end

% [trained_data, cluster_index] = log2vrp(indices, trained_data, k);

start_point = 0;
for j=1:length(indices)
    f = figure;
    f.Position = [10 10 800 1800];
    tiledlayout(4,2, 'Padding', 'none', 'TileSpacing', 'compact');
    log_range = trained_data(start_point+1 : start_point+indices(j),:);
    log_range = fakeCyle(log_range, k);
    for s = 1:8
        if s == 2
            theta = ((0:1:6)/6)*2*pi;
            angles = 0:60:360;
            marks = ['o';'*';'+';'^';'x';'d';'.'; '_'; '^';'v';'o'];
            centroids = C_original;
            %find value max in original data\

            for c = 1:size(centroids,2)
                colomnMax = max(centroids(:,c));
                colomnMin = min(centroids(:,c));
                centroids(:,c) = (centroids(:,c)-colomnMin)./(colomnMax-colomnMin);
            end
            centroids = [centroids, centroids(:,1)];
            rMax = max(max(centroids));
            colors = getColorFriendly(size(centroids, 1)); 
            subplot(4,2,2);
            labels = {'Crest'; 'SB'; 'CPP'; 'CSE'; 'Q_{\Delta}'; 'Q_{ci}'};
%             labels = {'CSE'; 'Q_{\Delta}'; 'Q_{ci}'};
            for L = 1:size(labels)
                labels{L} = join([string(labels(L)) ':' roundn(min(C_original(:, L)), -2) '~' roundn(max(C_original(:, L)), -2)], '');
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
            rlim([-0.1 rMax]);
            title 'Centroid Polar'
        else
            mSymbol = FonaDynPlotVRP(log_range, names, string(subplotNames(s)), subplot(4,2,s), 'ColorBar', 'on','PlotHz', 'on', 'MinCycles', 5);  
            pbaspect([1.5 1 1]);
            xlabel('Hz');
            ylabel('dB');
            grid on
            if isequal(string(subplotNames(s)) ,'maxCluster')
                subtitle('Phonation Clusters');
            else
                subtitle(string(subplotNames(s)));
            end
        end
    end
    
    vrp_dir = fullfile(recreated_vrp, file_dir(j+sysFolderN).name);
    if ~exist(vrp_dir, 'dir')
        mkdir (vrp_dir)
    end
    vrp_file = join([vrp_dir, '\', file_dir(j+sysFolderN).name, '_classification_k=', string(k), '_VRP.csv'], '');
    FonaDynSaveVRP(vrp_file, names, log_range);
       
    sgtitle(file_dir(j+sysFolderN).name);
    start_point = start_point + indices(j);
    
    % save as pdfs
    pdf_file = join([pdf_dir, '\',file_dir(j+sysFolderN).name, '_vrp_k=', string(k)],'');
    pdf_dir_s = join([subject_vrp,'\',file_dir(j+sysFolderN).name], '');
    if ~exist(pdf_dir_s, 'dir')
        mkdir(pdf_dir_s)
    end
    pdf_file_s = join([pdf_dir_s, '\',file_dir(j+sysFolderN).name, '_vrp_k=', string(k)],'');
%     set(gcf,'PaperPositionMode','Auto'); 
%     set(gcf,'PaperPosition',[4.65,-2.32,20.38,25.65]);
    set(gcf,'PaperOrientation','portrait');
    set(gcf, 'PaperSize', [30, 40]);
%     print(gcf, pdf_file,'-dpdf','-r600', '-bestfit');
%     print(gcf, pdf_file_s,'-dpdf','-r600', '-bestfit');
    close gcf;
end
centroid_excel = [centroid_excel; C_original; nan, nan, nan, nan,nan,nan];
end
centroid_file = join([main_folder, '\centroids.csv'], '');
writematrix(centroid_excel, centroid_file);
end


%% Plot BIC curves
figure('Name','Number of phonation types');
plot(spec_num_clusters, BIC(1,:), 'Color','b', 'LineWidth', 2);
hold on
plot(spec_num_clusters, BIC(2,:), 'Color','r', 'LineWidth', 2);
hold on
plot(spec_num_clusters, BIC(3,:), 'Color','k', 'LineWidth', 2);
h = zeros(3,1);
%     h(1) = plot(num_clusters, BIC(spec_num_clusters==num_clusters), '*', 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'LineWidth', 2);
h(1) = plot(4, BIC(1,4), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'b', 'LineWidth', 2);
h(2) = plot(3, BIC(2,3), '*', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 2);
h(3) = plot(2, BIC(3,2), 's', 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'LineWidth', 2);
xticks(spec_num_clusters)
xlabel('Number of phonation types')
ylabel('BIC')
ylim([160000, 210000]);
legend(h,'Estimated number for Male','Estimated number for Female','Estimated number for Children', 'Location','northeast')
set(gca, 'FontSize', 13)
hold off


%% Plot classification plots
clear all 
close all
Folder = 'L:\Huanchen\KinderEGG\Generated from VRP\Children\recreated_vrp';
File_dir = dir(Folder);
for i = 1:length(File_dir)
    % Remove system folders.
        if(isequal(File_dir(i).name,'.')||... 
           isequal(File_dir(i).name,'..')||...
           isequal(File_dir(i).name,'.DS_Store')||...
           ~File_dir(i).isdir)
            continue
        end
        f = figure;
        f.Position = [10 10 800 1800];
        tiledlayout(3,2, 'Padding', 'none', 'TileSpacing', 'compact');
        set(f, 'Position');
        Class_Folder = [File_dir(1).folder '\' File_dir(i).name '\']; 
        Class_Files = dir(strcat(Class_Folder,'*VRP.csv'));
        for j = 1:length(Class_Files)
            Class_name = Class_Files(j).name;
            subplot_title = Class_name(20:22);
            vrp_file = fullfile(Class_Files(j).folder, Class_Files(j).name);
            [names, Arrays] = FonaDynLoadVRP(vrp_file);
            FonaDynPlotVRP(Arrays, names, 'maxCluster', subplot(3,2,j), 'ColorBar', 'on', 'MinCycles', 5);  
            pbaspect([1.5 1 1]);
            grid on
            xlabel('MIDI');
            ylabel('dB');
            subtitle(subplot_title);
            set(gca, 'FontSize', 12);
        end
        sgtitle(sprintf('Figure S%s: Classification voice maps for participant %s', string(2*(i-3)-1+54),...
            Class_name(1:3)));
        pdf_name = fullfile('L:\Huanchen\KinderEGG\Generated from VRP\Children',...
            sprintf('%s_k=2-6.pdf', Class_name(1:3)));
        print(gcf, pdf_name,'-dpdf','-r600', '-bestfit');
        close gcf
        f = figure;
        f.Position = [10 10 800 1800];
        tiledlayout(3,2, 'Padding', 'none', 'TileSpacing', 'compact');
        set(f, 'Position');
        for j = 1:6
            metrics_name = {'Crest'; 'SpecBal';'CPPs';'Entropy';'dEGGmax';'Qcontact'};
            subplot_title = metrics_name(j);
            vrp_file = fullfile(Class_Files(1).folder, Class_Files(1).name);
            [names, Arrays] = FonaDynLoadVRP(vrp_file);
            FonaDynPlotVRP(Arrays, names, string(metrics_name(j)), subplot(3,2,j), 'ColorBar', 'on', 'MinCycles', 5);  
            pbaspect([1.5 1 1]);
            grid on
            xlabel('MIDI');
            ylabel('dB');
            subtitle(subplot_title);
            set(gca, 'FontSize', 12);
        end
        sgtitle(sprintf('Figure S%s: Acoustic and EGG Metric maps for participant %s', string(2*(i-3)+54),...
            Class_name(1:3)));
        pdf_name = fullfile('L:\Huanchen\KinderEGG\Generated from VRP\Children',...
            sprintf('%s_metrics.pdf', Class_name(1:3)));
        print(gcf, pdf_name,'-dpdf','-r600', '-bestfit');
        close gcf
end



function [data, indices] = extractData(DIR, type, varargin)
%type = file suffix '.vrp' or '.log'
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
                        vrp_array = rmoutliers(vrp_array, 'mean');
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
    % manually choose the needed metric pairs
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
    % log of degg is sometimes needed
%     metricsRep(:,5) = log10(metricsRep(:,5));
    [metricsStd, PS] = mapminmax(metricsRep',0,1);
    metricsStd = metricsStd';
    [metricsStd, metricsM, metricsDev] = zscore(metricsStd);
    cluster_names = [];

    [idx, C] = kmeans(metricsStd, k, 'Display','final','OnlinePhase', 'on','Replicates', 20, 'MaxIter',100000);
    
    marks = ['bo';'r*';'m+';'g^';'yx'; 'k.'; 'w_'; 'c|' ; 'bs'; 'rd'; ];
    [trained_data, Dic] = setClustersPos(data, idx, k);
    
    for kk =1:k
        cluster_name =join(['Cluster ', string(kk)], '');
        cluster_names = [cluster_names, cluster_name];
    end
    C_original = C .* metricsDev + metricsM;
    C_original = mapminmax('reverse', C_original',PS);
    C_original = C_original';
%     C_original(:,5) = 10 .^(C_original(:,5));
    C_original = C_original(Dic, :);
end

function [log_range] = fakeCyle(log_range,k)
    % create fake cycles = 100
    log_range(:, (end+1:end+k)) = zeros(size(log_range,1), k);
    for i = 1:k
        idx = find(log_range(:, 10) == i);
        log_range(idx, 10+i) = log_range(idx, 3);
    end
end

function [vrp_mat, start_point, cluster_index] = log2vrp(indices, log_metrics)
    % assign the generated log matrix to vrp format matrix
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


function [mean_vrp] = combineVRP(vrp_mat, k)
    mean_vrp = zeros(15000,10+k);
    vrp_mat = [vrp_mat, zeros(size(vrp_mat,1),k)];
    n = 1;
    for x = 1:100
        for y = 1:150
            pair = find(vrp_mat(:,1) == x & vrp_mat(:,2) == y);
            if ~isempty(pair)
                mean_vrp(n, 1:2) = [x,y];
                mean_vrp(n, 3) = sum(vrp_mat(pair, 3));
                mean_vrp(n, 4:9) = mean(vrp_mat(pair, 4:9), 1);
                for i = 1:length(pair)
                    addPosition = vrp_mat(pair(i), 10);
                    vrp_mat(pair, 10+addPosition) = vrp_mat(pair, 3);
                end
                mean_vrp(n, 11:end) = sum(vrp_mat(pair, 11:end), 1);
                mean_vrp(n, 10) = find(mean_vrp(n, 11:end) == max(mean_vrp(n, 11:end)),1);
                n = n+1;
            end
            
        end
    end
    
    mean_vrp(n, 11:end) = sum(vrp_mat(pair, 11:end), 1);
    mean_vrp(all(mean_vrp==0, 2),:)=[];
end


%set clusters color by the vertical position, so bottom cluster is always No.1
function [trained, Dic] = setClustersPos(data, idx, k)
    meanValue = [];
    trained = data;
    trained(:, end+1) = zeros(size(trained,1), 1);
    for i = 1:k
        meanValue(i) = mean(data(idx == i, 3));
    end
    [order, Dic] = sort(meanValue);
    for ii = 1:k
        for j = 1:k
            if meanValue(j) == order(ii)
                trained(idx==j, end) = ii;
            end
        end
    end
end

function [axisl, axisb, axisw, axish] = getSubplotWH(n, ncols, nrows)
    axisw = (1 / ncols) * 0.95;
    axish = (1 / nrows) * 0.9;
    row = floor(n /(ncols+1) ) +1;
    col = mod(n-1, ncols) +1;
    axisl = (axisw+0.02) * (col - 1);
    axisb = (axish+0.02) * (row-1);
end


function [Fx, Fy] = getGradient(data)
    Fx = [];
    Fy = [];
    for col = 1:6
        dx = [];
        dy = [];
        xmin = min(data(:,1));
        xmax = max(data(:,1));
        ymin = min(data(:,2));
        ymax = max(data(:,2));
        ym = data(:, 2);
        xm = data(:, 1);
        zm = data(:, col+3);
        FDATATEST=scatteredInterpolant(xm, ym, zm, 'nearest', 'none');
        dspl=1.0;  % use 1 for contours/quivers
        df0=1.0;
        [xq,yq]=meshgrid(xmin:df0:xmax, ymin:dspl:ymax);
        vq=FDATATEST(xq,yq);
        [px,py] = gradient(vq,100,100);
        for i = 1:size(data,1)
            x = data(i,1)-xmin+1;
            y = data(i,2)-ymin+1;
            if isnan(px(y,x))
                px(y,x) = 0;
            end
            if isnan(py(y,x))
                py(y,x) = 0;
            end
            dx = [dx; px(y,x)];
            dy = [dy; py(y,x)];
        end
        Fx = [Fx, dx];
        Fy = [Fy, dy];
    end
end