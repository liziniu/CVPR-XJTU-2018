function [Ix, Ex, rmask] = rmVerSeam(I, Mx, Tbx, mask)
% I is the image. Note that I could be color or grayscale image.
% Mx is the cumulative minimum energy map along vertical direction.
% Tbx is the backtrack table along vertical direction.
% Ix is the image removed one column.
% E is the cost of seam removal

[ny, nx, nz] = size(I);
rmIdx = zeros(ny, 1);
Ix = uint8(zeros(ny, nx-1, nz));
rmask = zeros(ny, nx-1);
%% Add your code here
Ex = min(Mx(end,:));
index = find(Mx(end, :) == Ex);
for j = ny:-1:2
    Ix(j, 1:index-1, :) = I(j, 1:index-1, :);
    rmask(j, 1:index-1) = mask(j, 1:index-1);
    Ix(j, index:end, :) = I(j,index+1:end, :);
    rmask(j, index:end) = mask(j, index+1:end);
    index = Tbx(j, index);
end
