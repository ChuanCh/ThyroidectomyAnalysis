% Creates the data set used in Table 1 and Fig. 1 of
%
% [1] F. K. Teklehaymanot, M. Muma, and A. M. Zoubir, "Novel Bayesian Cluster
%     Enumeration Criterion for Cluster Analysis With Finite Sample Penalty Term", 
%     in Proc. 43rd IEEE Int. conf. on Acoustics, Speech and Signal Process. (ICASSP), pp. 4274-4278, 2018, 
%     [Online-Edition: https://www.researchgate.net/publication/322918028]

% Inputs: 
%        num_samples_cluster - a scalar containing the number of samples in each cluster
%        plotting - plotting option

% Outputs:
%        data - the generated data set
%        num_features - number of features in the generated data set
%        num_samples_total - total number of samples in the data set
%        num_clusters - true number of clusters in the data set


function [data, num_features, num_samples_total, num_clusters] = generateData(num_samples_cluster, plotting)

% Initializations
num_features = 2; % number of features in the data set
num_clusters = 5; % the true number of clusters in the data set
num_samples_total = num_clusters*num_samples_cluster; % total number of samples in the data set (the clusters have the same number of samples)
cluster_centroids = cell(1,num_clusters); % cluster centroids
cluster_covmats = cell(1,num_clusters); % cluster covariance matrices
data = zeros(num_features,num_samples_total); % initialize the data set

% Cluster centroids
cluster_centroids{1} = [-2; 0]; 
cluster_centroids{2} = [5; 0]; 
cluster_centroids{3} = [0; 7]; 
cluster_centroids{4} = [8; 4]; 
cluster_centroids{5} = [3; 10]; 

% Cluster covariance matrices
cluster_covmats{1} = diag([0.2; 0.2]); 
cluster_covmats{2} = diag([0.6; 0.6]); 
cluster_covmats{3} = diag([0.4; 0.4]); 
cluster_covmats{4} = diag([0.2; 0.2]); 
cluster_covmats{5} = diag([0.3; 0.3]); 
 

% Generate Gaussian distributed samples

cluster_labels = [ones(num_samples_cluster,1); repmat(2,num_samples_cluster,1); repmat(3,num_samples_cluster,1); repmat(4,num_samples_cluster,1); repmat(5,num_samples_cluster,1)]; % cluster label of each sample in the data set

for n = 1:num_samples_total
    data(1:num_features,n) = mvnrnd(cluster_centroids{cluster_labels(n)}, cluster_covmats{cluster_labels(n)});
end


% plot the generated data set
if plotting == 1
    figure('Name','Generated data set');
    plot(data(1,cluster_labels==1), data(2,cluster_labels==1), 'k*')
    hold on
    plot(data(1,cluster_labels==2), data(2,cluster_labels==2), 'k*')
    plot(data(1,cluster_labels==3), data(2,cluster_labels==3), 'k*')
    plot(data(1,cluster_labels==4), data(2,cluster_labels==4), 'k*')
    plot(data(1,cluster_labels==5), data(2,cluster_labels==5), 'k*')
    xlabel('Feature 1')
    ylabel('Feature 2')
    set(gca, 'FontSize', 13)
    hold off
end

end

