function [A, inlineridxs] = est_optimal_Affine_ransac(points1, points2, ntrials)
% estimate the fundamental matrix using two set of points
% using ransac to estimate the fundamental matrix

% check the input
if(any(size(points1) ~= size(points2)))
    error('The points should be given in pair!');
end

if(size(points1,2) ~= 2)
   error('The points should be given in Nx2 format!'); 
end

% get the number of points
N = size(points1,1);
if(N < 3)
    error('At least 3 points are required!');
end

% check the number of trials for fundamental
if(ntrials < 20)
    ntrials = 20;
end

% set the random state
seed = 1234;
RNDN_STATE = randn('state');  %#ok<*RAND>
randn('state', seed);
RND_STATE = rand('state');
rand('twister', seed);

% do the random experiments
inliners = cell(ntrials,2);
num_inliners = zeros(ntrials,1);
th_inliner = 20;
for i = 1 : ntrials
    % randomly picking 3 point
    y = randsample(N,3);
    
    
    % estimate the fundamental matrix
    F = est_optimal_affine(points1(y,:), points2(y,:));
    inliners{i,1} = F;
    
%     if(abs(F(1,1)-0.94)<0.1 && abs(F(2,2)-0.96)<0.1 && abs(F(1,3)-626)<50 && abs(F(2,3)-310)<50)
%         inDebug = 1;
%     end
%     F=[0.9432 0.0851 626.1134;-0.0108 0.9631 310.9023];
    
    % get the inliner indexes
    L12 = affine_transform(F, points1);
    d = sqrt(sum((L12 - points2).^2,2));
    % d = diag(points2 * F * points1');
    inliners{i,2} = find(abs(d) < th_inliner);
    
    
    % get the number of inlines
    num_inliners(i) = length(inliners{i, 2});
end

% get the optimal solutions
[~,idx] = max(num_inliners);
A = inliners{idx,1};
inlineridxs = inliners{idx,2};