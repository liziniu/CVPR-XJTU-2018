
function y = affine_transform(A, x)
% the affine transform for the given points

if(size(x,2) ~= 2)
    error('The input x should be in Nx2 format!');
else
    x = [x ones(size(x,1),1)];
end

if(size(A,1) ~= 2 || size(A,2) ~= 3)
    error('The input A should be in 2 x 3 format!');
end

y = A * x';
y = y';