%% Novel Bayesian Cluster Enumeration Criterion for Cluster Analysis With Finite Sample Penalty Term

% For details, see: 
% [1] F. K. Teklehaymanot, M. Muma, and A. M. Zoubir, "Novel Bayesian Cluster
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
%        num_features - a scalar containing the number of features in the data set
%        est_num_samples_cluster - a vector containing the estimated number of samples in each cluster
%        est_cluster_covmats - a cell containing the estimated cluster covariance matrices
%        dup_mat - duplication matrix of the covariance matrix


% Outputs:
%        data_term - data fidelty term of BIC_NF 
%        penalty_term - penalty term of BIC_NF
%        BIC - the calculated Bayesian information criterion


function [data_term, penalty_term, BIC] = BIC_NF(num_features, est_num_samples_cluster, est_cluster_covmats, dup_mat)

l = length(est_num_samples_cluster); % number of clusters
q = num_features*(num_features+3)/2; % number of estimated model parameters per cluster
log_sigma = zeros(l,1);
log_penalty = zeros(l,1);

for m = 1:l
    log_sigma(m) = log(det(est_cluster_covmats{m}));
    F = kron(inv(est_cluster_covmats{m}),inv(est_cluster_covmats{m}));
    log_penalty(m) = log(det(dup_mat'*F*dup_mat)); 
end

data_term = est_num_samples_cluster*log(est_num_samples_cluster)' - est_num_samples_cluster*log_sigma/2;
penalty_term = -q/2*sum(log(est_num_samples_cluster)) + num_features*(num_features+1)/4*log(2)*l + .5*sum(log_sigma) - .5*sum(log_penalty);
BIC = data_term + penalty_term;

end
