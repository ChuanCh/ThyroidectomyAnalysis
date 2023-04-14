%% The original Bayesian Information Criterion (BIC) as a wrapper around the EM algorithm

% For details, see: 
%
% [1] G. Schwarz, "Estimating the Dimension of a Model", Ann. Stat., 
%     vol. 6, no.2, pp. 461-464, 1978.
%
% [2] J. E. Cavanaugh and A. A. Neath, "Generalizing The Derivation Of The
%     Schwarz Information Criterion", Commun. Statist.-Theory Meth., 
%     vol. 28, no. 1, pp. 49-66, 1999.
%
% [3] F. K. Teklehaymanot, M. Muma, and A. M. Zoubir, "Bayesian Cluster Enumeration Criterion for Unsupervised Learning",
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
%        num_features - a scalar containg the number of features in the data set
%        num_samples_total - a scalar containing the total number of samples in the data set
%        est_num_samples_cluster - a vector containing the number of data points in each cluster
%        est_cluster_covmats - a cell containing estimated covariance matrices


% Outputs:
%        data_term - data fidelity term of BIC_O 
%        penalty_term - penality term of BIC_O
%        BIC - the calculated Bayesian information criterion


function [data_term, penalty_term, BIC] = BIC_O(num_features, num_samples_total, est_num_samples_cluster, est_cluster_covmats)

l = length(est_num_samples_cluster); % number of clusters
q = num_features*(num_features+3)/2; % number of estimated model parameters per cluster
log_sigma = zeros(l,1);

for m = 1:l
    log_sigma(m) = log(det(est_cluster_covmats{m}));
end

data_term = est_num_samples_cluster*log(est_num_samples_cluster)' - est_num_samples_cluster*log_sigma/2;
penalty_term = -q/2*l*log(num_samples_total); 
BIC = data_term + penalty_term;

end
