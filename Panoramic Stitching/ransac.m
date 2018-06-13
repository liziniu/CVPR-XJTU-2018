function best_H = ransac(l1, l2, index_pairs)
% 估计最好的单应矩阵
% l1: n1 x 2, [x, y], [second, first]
% l2: n2 x 2, [x, y], [second, first]
% index_pairs: n x 2, [index1, index2]

if size(l1, 2) ~= 2
    error('location 1 should be nx2');
end
if size(l2, 2) ~=2
    error('location 2 should be nx2');
end
if size(index_pairs, 2) ~= 2
    error('index_pairs should be nx2');
end
if size(index_pairs, 1) ~= length(unique(index_pairs(:, 1))) || size(index_pairs, 1) ~= length(unique(index_pairs(:, 2)))
    error('index_pairs affination should be unique');
end


% the following will be [x, y]
if ~exist('min_pix', 'var')
    min_pix = 5;
end
if ~exist('n_try', 'var')
    n_try = 30;
end

n = size(index_pairs, 1);
l1 = l1(index_pairs(:, 1), :);
l2 = l2(index_pairs(:, 2), :);

best_H = [];
best_count = -inf;
for i = 1: n_try
    u = []; v = []; 
    p = randperm(n, 4);
    for j = 1: 4
        u = [u; l1(p(j), 1), l1(p(j), 2)];    % first image
        v = [v; l2(p(j), 1), l2(p(j), 2)];    % second image
    end
    H = get_H(u, v);                          % 3x3
    
    l2_cat = cat(2, l2, ones(n, 1));            % nx3
    l2_aff = H * l2_cat';                       % 3x3 x 3xn = 3xn 
    l2_aff_q = [l2_aff(1, :)./ (l2_aff(3, :)+1e-10) ;     % 
                l2_aff(2, :)./ (l2_aff(3, :)+1e-10) ];    % 2xn
    l2_aff_q = l2_aff_q';                       % nx2
    abs_diff = abs(l2_aff_q(:, 1) - l1(:, 1)) + abs(l2_aff_q(:, 2) - l1(:, 2));
    count = length(find(abs_diff < min_pix));
    if count > best_count
        best_count = count;
        best_H = H;
    end        
end
