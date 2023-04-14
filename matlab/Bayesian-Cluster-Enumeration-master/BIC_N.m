%% Bayesian cluster enumeration criterion for unsupervised learning 

% For details, see article: 
% [1] F. K. Teklehaymanot, M. Muma, and A. M. Zoubir, "Bayesian Cluster Enumeration Criterion for Unsupervised Learning",
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
%        num_features - a scalar containing the number of features in the data set
%        est_num_samples_cluster - a vector containing the estimated number of samples in each cluster
%        est_cluster_covmats - a cell containing the estimated covariance matrices


% Outputs:
%        data_term - data fidelty term of BIC_N
%        penalty_term - penalty term of BIC_N
%        BIC - the calculated BIC


function [data_term, penalty_term, BIC] = BIC_N(num_features, est_num_samples_cluster, est_cluster_covmats)

l = length(est_num_samples_cluster); % number of clusters
q = num_features*(num_features+3)/2; % number of estimated model parameters per cluster
log_sigma = zeros(l,1);

for m = 1:l
    log_sigma(m) = log(det(est_cluster_covmats{m}));
end

data_term = est_num_samples_cluster*log(est_num_samples_cluster)' - est_num_samples_cluster*log_sigma/2;  
penalty_term = -q/2*sum(log(est_num_samples_cluster)); 

BIC = data_term + penalty_term;

end
