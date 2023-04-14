%% The main file that runs Bayesian cluster enumeration algorithms

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


% Outputs:
%         est_num_clusters: estimated number of clusters in the observed data set
%         est_cluster_centroids: estimated cluster centroids
%         est_cluster_covmats: estimated cluster covariance matrices


close all;
clear all;
warning off;


%% User inputs
spec_num_clusters = 1:10; % the number of clusters specified by a family of candidate models
num_samples_cluster = 1000; % number of samples per cluster
criterion = 'BIC_N'; % type of cluster enumeration criterion % possible inputs are 'BIC_N', 'BIC_NF', 'BIC_O', 'BIC_OS' (See [1] and [2] for details on the criteria)
plotting = 1; % if set to 1 it plots the raw data and the calculated Bayesian Information Criterion (BIC) as a function of the specified number of clusters by the candidate models 

%% Generate data
[data, num_features, num_samples_total, num_clusters] = generateData(num_samples_cluster, plotting);

%% Perform Bayesian cluster enumeration
[est_num_clusters, est_cluster_centroids, est_cluster_covmats] = performBayesianClusterEnumeration(A', 3, size(A,1), criterion, spec_num_clusters, 1, plotting); %remove outliers first

