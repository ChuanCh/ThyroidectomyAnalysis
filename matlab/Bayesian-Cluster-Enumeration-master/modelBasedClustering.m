%% Model based clustering algorithm (the EM algorithm)

% For details, see: 
%
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
%        data - a matrix containg the data set which is going to be clustered 
%        num_features - a scalar containing the number of features in the data set
%        num_samples_total - a scalar containing the total number of samples in the data set
%        spec_num_cluster - a scalar containing the number of clusters specified by a candidate model
%        est_centroids - a matrix that contains the initial cluster centroids estimated by K-means++
%        cluster_memberships - a vector that contains cluster memberships of each data point 


% Outputs: 
%         est_centroids - estimated cluster centroids for the specified candidate model
%         est_covmats - estimated cluster covariance matrices for the specified candidate model
%         est_prob - estimated probability of membership of each sample to
%         each cluster


function [est_centroids, est_covmats, est_prob] = modelBasedClustering(data, num_features, num_samples_total, spec_num_cluster, est_centroids, cluster_memberships)

    %% Initialization method for the EM algorithm
    
    est_prob = zeros(num_samples_total, spec_num_cluster); % estimated probability of membership of each sample to each cluster
    reg_value = 1e-6; % regularization value used to regularize the covariance matrix
    limit = 1e-6; % a value that determines when the EM algorithm should terminate
    iterations = 200; % maximum number of iterations of the EM algorithm
    log_likelihood = zeros(2,iterations); % initialize the log-likelihood 
    est_covmats = cell(1,spec_num_cluster); % initialize the estimated covariance matrices
    est_mixing_coef = zeros(1,spec_num_cluster); % initialize the estimated mixing coefficients
    data_cluster = cell(1,spec_num_cluster);

    % Generate Gaissian Mixture Models (GMMs) from the K-means++
    % initializations
    for m = 1:spec_num_cluster

        data_cluster{m} = data(:,cluster_memberships==m);
        est_num_samples_cluster = size(data_cluster{m},2); % number of data samples in the mth cluster
        est_mixing_coef(m) = est_num_samples_cluster/num_samples_total; % mixing coefficient of the mth cluster
        distance = bsxfun(@minus, data_cluster{m}, est_centroids(:,m));
        est_covmats{m} = 1/est_num_samples_cluster*(distance*distance');

        % Check if the covariance matrix is positive definite
        [~, indicator] = chol(est_covmats{m});
        
        if  indicator ~= 0
            est_covmats{m} = 1/(num_features*est_num_samples_cluster)*sum(diag(distance'*distance))*eye(num_features); % diagonal covariance matrix whose diagonal entries are identical
            [~,indicator] = chol(est_covmats{m});
            
            if indicator ~= 0
                est_covmats{m} = eye(num_features); % if the estimated covariance matrix is singular, then set it to identity
            end
            
        end

        data_centered = bsxfun(@minus, data, est_centroids(:,m)); 
        [Lower_triang_mat, ~] = chol(est_covmats{m},'lower');
        temp_dist = Lower_triang_mat\data_centered;
        mahalanobis_distance = dot(temp_dist, temp_dist, 1)/2;  
        log_norm_factor = -num_features*log(2*pi)/2 - sum(log(diag(Lower_triang_mat)));
        est_prob(:,m) = log_norm_factor - mahalanobis_distance; 

    end

    est_prob = bsxfun(@plus, est_prob, log(est_mixing_coef));
    log_likelihood(1) = sum(log(sum(exp(est_prob),2)));  


    %% Perform the EM algorithm 

    for i = 2:iterations

        % Expectation-step
        est_prob = zeros(num_samples_total, spec_num_cluster);
        
        for m = 1:spec_num_cluster
            
            data_centered = bsxfun(@minus, data, est_centroids(:,m));
            [Lower_triang_mat, ~] = chol(est_covmats{m},'lower');
            temp_dist = Lower_triang_mat\data_centered;
            mahalanobis_distance = dot(temp_dist,temp_dist,1)/2;  
            log_norm_factor = -num_features*log(2*pi)/2 - sum(log(diag(Lower_triang_mat)));
            est_prob(:,m) = log_norm_factor - mahalanobis_distance;
            
        end
        
        est_prob = bsxfun(@plus, est_prob, log(est_mixing_coef));
        est_prob_norm = log(sum(exp(est_prob), 2));
        est_prob = exp(bsxfun(@minus, est_prob, est_prob_norm));

        % Maximization-step
        est_num_samples_cluster = sum(est_prob, 1);
        est_prob_squared = sqrt(est_prob); 
        est_centroids = bsxfun(@times, data*est_prob, 1./est_num_samples_cluster); 
        est_mixing_coef = est_num_samples_cluster/num_samples_total; 
        
        for m = 1:spec_num_cluster  
            
            data_centered = bsxfun(@minus, data, est_centroids(:,m));
            temp = bsxfun(@times, data_centered, est_prob_squared(:,m)');
            est_covmats{m} = temp*temp'/est_num_samples_cluster(m) + reg_value*eye(num_features);  
        
        end

        % Check for convergence
        est_prob = zeros(num_samples_total, spec_num_cluster);
        
        for m = 1:spec_num_cluster
            
            data_centered = bsxfun(@minus, data, est_centroids(:,m));
            [Lower_triang_mat, ~] = chol(est_covmats{m}, 'lower');
            temp_dist = Lower_triang_mat\data_centered;            
            mahalanobis_distance = dot(temp_dist,temp_dist,1)/2;  
            log_norm_factor = -num_features*log(2*pi)/2 - sum(log(diag(Lower_triang_mat)));
            est_prob(:,m) = log_norm_factor - mahalanobis_distance;
            
        end
        
        est_prob = bsxfun(@plus, est_prob, log(est_mixing_coef));
        log_likelihood(i) = sum(log(sum(exp(est_prob), 2)));
        
        if abs(log_likelihood(i)-log_likelihood(i-1)) < limit
            break;
        end   
    end

end
