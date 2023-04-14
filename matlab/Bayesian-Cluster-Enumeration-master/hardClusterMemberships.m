%% Using the clustering results of the model based clustering function (modelBasedClustering.m), this function provides hard cluster memberships to each data point in
% the data set

% See Algorithm 1 in [1] for details:
% [1] F. K. Teklehaymanot, M. Muma, and A. M. Zoubir, "A Novel
%     Bayesian Cluster Enumeration Criterion for Unsupervised Learning",
%     IEEE Trans. Signal Process. (accepted),
%     [Online-Edition: https://arxiv.org/abs/1710.07954v2], 2018.

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
%        spec_num_cluster - a scalar containing the number of clusters specified by a candidate model
%        est_prob - a matric containing the estimated probability of membership of each sample to each cluster


% Outputs: 
%         cluster_labels - hard cluster memberships
%         est_num_samples_cluster - estimated number of samples in each cluster


function [cluster_labels, est_num_samples_cluster] = hardClusterMemberships(est_prob, spec_num_cluster)

    [~,cluster_labels] = max(est_prob,[],2);
    est_num_samples_cluster = zeros(1,spec_num_cluster);

    for m = 1:spec_num_cluster
        est_num_samples_cluster(m) = sum(m==cluster_labels);
    end

end
