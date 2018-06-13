function H = get_H(u, v)

if size(u, 2)~=2
    error("U should be Nx2 format");
end
if size(v, 2)~=2
    error("V should be Nx2 format");
end
if size(u, 1)~= size(v, 1)
    error("U and V should have the same dimension in the 1st dimension");
end

% 根据特征点估计单应矩阵
% u: 4x2
% v: 4x2

A = [];
n = size(u, 1);
for i = 1 : n
    A = [A; 
        v(i, 1), v(i, 2),   1,         0,        0,    0,  -v(i, 1) * u(i, 1), -v(i, 2) * u(i, 1), -u(i, 1);
              0,       0,   0,   v(i, 1),  v(i, 2),    1,  -v(i, 1) * u(i, 2), -v(i, 2) * u(i, 2), -u(i, 2)];
end

% AH = 0;
% 8道题
% 3道：解析概念
% 2道：证明
% 3道：全计算
[U, S, V] = svd(A);
h = V(:, end);

H = [h(1:3)'; h(4:6)';h(7:9)'];
end