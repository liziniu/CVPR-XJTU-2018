function [Ix, Ex] = rmVerSeam(I, Mx, Tbx)
% I is the image. Note that I could be color or grayscale image.
% Mx is the cumulative minimum energy map along vertical direction.
% Tbx is the backtrack table along vertical direction.
% Ix is the image removed one column.
% E is the cost of seam removal

[ny, nx, nz] = size(I);
rmIdx = zeros(ny, 1);
Ix = uint8(zeros(ny, nx-1, nz));

%% Add your code here
Ex = min(Mx(end,:));
index = find(Mx(end, :) == Ex);
for j = ny:-1:2
    Ix(j, 1:index-1, :) = I(j, 1:index-1, :);
    Ix(j, index:end, :) = I(j,index+1:end, :);
    index = Tbx(j, index);
end