%% The original Bayesian Information Criterion (BIC) as a wrapper around the K-means++ algorithm

% For details, see: 
%
% [1] D. Pelleg and A. Moore, "X-means: extending K-means with efficient
%     estimation of the number of clusters," in Proc. 17th Int. Conf. Mach.
%     Learn. (ICML), pp. 727-734, 2000.
%
% [2] F. K. Teklehaymanot, M. Muma, and A. M. Zoubir, "Bayesian Cluster Enumeration Criterion for Unsupervised Learning",
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
%        data - a matrix that contains the data set with diamensions num_features x num_samples
%        num_features - a scalar containg the number of features in the data set
%        num_samples_total - a scalar containing the total number of samples in the data set
%        spec_num_cluster - a scalar containing the number of clusters specified by a candidate model
%        est_centroids - a matrix containing the initial centroid estimates 


% Outputs:
%        data_term - data fidelity term of BIC_OS 
%        penalty_term - penality term of BIC_OS
%        BIC - the calculated Bayesian information criterion


function [data_term, penalty_term, BIC] = BIC_OS(data, num_features, num_samples_total, spec_num_cluster, est_centroids)

est_num_samples_cluster = zeros(spec_num_cluster,1); % initialize the number of data points in each cluster
sigma_interm = zeros(1,spec_num_cluster); % initialize the intermediate value of the variance
zeta = spec_num_cluster*num_features + 1; % number of estimated parameters

% Perform K-means to furthur refine the cluster centroids
[labels,est_centroids] = kmeans(data', spec_num_cluster, 'Start', est_centroids);
labels = labels'; % adjust its dimension (1 x num_samples_total)
est_centroids = est_centroids'; % adjust its dimension (num_features x spec_num_clusters)

for m = 1:spec_num_cluster
    est_num_samples_cluster(m) = sum(labels==m);
    dist = bsxfun(@minus, data(:,labels==m), est_centroids(:,m));
    sigma_interm(m) = sum(diag(dist'*dist));
end
sigma_hat = 1/(num_features*num_samples_total)*sum(sigma_interm);

data_term = est_num_samples_cluster'*log(est_num_samples_cluster) - num_features*num_samples_total/2*log(sigma_hat);
penalty_term = -zeta/2*log(num_samples_total);
BIC = data_term + penalty_term;

end

