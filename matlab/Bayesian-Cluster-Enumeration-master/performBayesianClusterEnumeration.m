%% Bayesian Cluster Enumeration Algorithms

% For details, see: 
%
% [1] F. K. Teklehaymanot, M. Muma, and A. M. Zoubir, "Bayesian Cluster Enumeration Criterion for Unsupervised Learning",
%     IEEE Trans. Signal Process. (accepted),
%     [Online-Edition: https://arxiv.org/abs/1710.07954v2], 2018.
%
% [2] F. K. Teklehaymanot, M. Muma, and A. M. Zoubir, "Novel Bayesian Cluster
%     Enumeration Criterion for Cluster Analysis With Finite Sample Penalty Term", 
%     in Proc. 43rd IEEE Int. conf. on Acoustics, Speech and Signal Process. (ICASSP), pp. 4274-4278, 2018, 
%     [Online-Edition: https://www.researchgate.net/publication/322918028]

% Copyright (c) 2018 Freweyni K. Teklehaymanot. All rights reserved.

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU Affero General Public License as published
% by the Free Software Foundation, version 3 of the License.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Affero General Public License for more details.

% You should have received a copy of the GNU Affero General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


% Inputs:
%        data - a matric containing the data set whose cluster number will be estimated
%        num_features - a scalar containing the number of features in the data set
%        num_samples_total - a scalar containing the total number of samples in the data set
%        criterion - a string that indicates the type of cluster enumeration criterion
%        spec_num_clusters - a vector containing the number of clusters specified by a family of candidate models
%        num_clusters - a scalar that contains the true number of clusters in the data set
%        plotting - a binary variable that indicates whether a figure will
%        be generated or not


% Outputs:
%         est_num_clusters: estimated number of clusters
%         est_cluster_centroids: estimated cluster centroids
%         est_cluster_covmats : estimated cluster covariance matrices


function [est_num_clusters, est_cluster_centroids, est_cluster_covmats] = performBayesianClusterEnumeration(data, num_features, num_samples_total, criterion, spec_num_clusters, num_clusters, plotting)
    

BIC = zeros(1,length(spec_num_clusters)); % initialize the Bayesian information criterion
est_centroids_EM = cell(1, length(spec_num_clusters)); % estimated cluster centroids for each candidate model
est_covmats_EM = cell(1, length(spec_num_clusters)); % estimated cluster covariance matrices for each candidate model


%% Calculate the Bayesian information criterion

for l=1:length(spec_num_clusters)

    [cluster_memberships_kmeans, est_centroids_Kmeans] = kmeans(data', spec_num_clusters(l), 'MaxIter', 300, 'Replicates', 10); % initialize the centroid estimates using K-means++  
    [est_centroids_EM{l}, est_covmats_EM{l}, est_prob] = modelBasedClustering(data, num_features, num_samples_total, spec_num_clusters(l), est_centroids_Kmeans', cluster_memberships_kmeans); % cluster the data set into spec_num_clusters(l) clusters using the EM algorithm
    [~, est_num_samples_cluster] = hardClusterMemberships(est_prob, spec_num_clusters(l)); % perform hard clustering, see [1] for details
    dup_mat = duplicationMatrix(num_features); % compute the duplication matrix of the covariance matrix

    if strcmp(criterion, 'BIC_NF') 
        
        [~, ~, BIC(l)] = BIC_NF(num_features, est_num_samples_cluster, est_covmats_EM{l}, dup_mat);
        
    elseif strcmp(criterion, 'BIC_O')
        
        [~, ~, BIC(l)] = BIC_O(num_features, num_samples_total, est_num_samples_cluster, est_covmats_EM{l});
        
    elseif strcmp(criterion, 'BIC_OS')
        
        [~, ~, BIC(l)] = BIC_OS(data, num_features, num_samples_total, spec_num_clusters(l), est_centroids_Kmeans);
        
    else
        
        [~, ~, BIC(l)] = BIC_N(num_features, est_num_samples_cluster, est_covmats_EM{l});
        
    end

end


%% Estimate the number of clusters and identify the corresponding cluster centroids and covariance matrices
% Method: using the global maximum
[~, max_ind] = max(BIC);
est_num_clusters = spec_num_clusters(max_ind); 

est_cluster_centroids = est_centroids_EM{max_ind};
est_cluster_covmats = est_covmats_EM{max_ind};


%% Plot results
if plotting == 1
    figure('Name','Number of phonation types');
    plot(spec_num_clusters, BIC, 'Color','b', 'LineWidth', 2)
    hold on
    h = zeros(2,1);
%     h(1) = plot(num_clusters, BIC(spec_num_clusters==num_clusters), '*', 'MarkerSize', 10, 'MarkerEdgeColor', 'k', 'LineWidth', 2);
    h(2) = plot(est_num_clusters, BIC(max_ind), 'o', 'MarkerSize', 10, 'MarkerEdgeColor', 'r', 'LineWidth', 2);
    xticks(spec_num_clusters)
    xlabel('Number of clusters specified by candidate models')
    ylabel('BIC')
    legend(h,'True number of clusters','Estimated number of clusters', 'Location','southeast')
    set(gca, 'FontSize', 13)
    hold off
end
    
end

