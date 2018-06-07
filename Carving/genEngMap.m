function e = genEngMap(I,mask, type)
% I is an image. I could be of color or grayscale.
% e is the energy map of n-by-m matrix.

if(~exist('type', 'var'))
    type = 'NC';
end

if(~exist('mask', 'var'))
    [h, w] = size(I);
    mask = zeros(h, w);
end


if ndims(I) == 3
    % Assume the image fed in is a 3-channel RGB color image
    Ig = double(rgb2gray(I)); 
else
    % Assume the image fed in is a grayscale image
    Ig = double(I);
end

[gx, gy] = gradient(Ig);
e = abs(gx) + abs(gy);
if strcmp(type, 'remove')
    e(logical(mask)) = -1;
end
if strcmp(type, 'remain')
    e(logical(mask)) = inf;
end
