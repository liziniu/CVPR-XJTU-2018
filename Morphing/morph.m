function morphed_im = morph(im1, im2, im1_pts, im2_pts, warp_frac, dissolve_frac)
% im1: the 1st image
% im2: the 2nd image
% im1_pts: n x 2 double
% im2_pts: n x 2 double
% warp_frac: [0,1], parameter to control shape warping, 0->1 <==> im1->im2
% dissolve_frac: [0,1], parameter to control cross-dissolve

assert(size(im1,3) == 3 & size(im2,3) == 3);
assert(size(im1,1) == size(im2,1) & size(im1,2) == size(im2,2));

if(~exist('warp_frac', 'var'))
    warp_frac = 0.5;
end
if(~exist('dissolve_frac', 'var'))
    dissolve_frac = 0.5;
end

%% Compute triangulation structure

% tri: m x 3 double, m is the number of triangles
% Each row of TRI specifies a triangle defined by indices with respect to
% the points.

% tri_im1 = delaunay(im1_pts(:,1), im1_pts(:,2));
% tri_im2 = delaunay(im2_pts(:,1), im2_pts(:,2));
% figure; triplot(tri_im1, im1_pts(:,1), im1_pts(:,2));
% figure; triplot(tri_im2, im2_pts(:,1), im2_pts(:,2));

% We need to generate only one triangulation and use it on both point sets
% Node im1_pts & im2_pts are in format (col row), other point sets are (row col)
tri = delaunay(im1_pts(:,1),im1_pts(:,2));     % 顶点索引构成的三角剖分
x_mean = (1 - warp_frac) * im1_pts(:,2) + warp_frac * im2_pts(:,2);
y_mean = (1 - warp_frac) * im1_pts(:,1) + warp_frac * im2_pts(:,1);

% tri = delaunay(x_mean, y_mean);
% figure; triplot(tri, x_mean, y_mean);

%% target image: compute which triangle each pixel belongs to

d = size(im1);
[y, x] = meshgrid(1:d(2), 1:d(1));
x_temp = x';
y_temp = y';
im_mesh = [x_temp(:) y_temp(:)]; % (row col), eg. [1 1; 1 2; 1 3; 2 1; 2 2; 2 3]

pts_mean = [x_mean, y_mean]; % (row col)

[t, P] = tsearchn(pts_mean, tri, im_mesh); % t is triangle index for each pixel

%% target image: compute barycentric coordinate

barycentric = zeros(length(t),3);

for i = 1 : length(t)
    if isnan(t(i))
        barycentric(i,:) = [NaN, NaN, NaN];
        continue;
    end
    ax = pts_mean(tri(t(i),1), 1);
    bx = pts_mean(tri(t(i),2), 1);
    cx = pts_mean(tri(t(i),3), 1);
    ay = pts_mean(tri(t(i),1), 2);
    by = pts_mean(tri(t(i),2), 2);
    cy = pts_mean(tri(t(i),3), 2);
    A = [ax, bx, cx;
         ay, by, cy;
         1,  1,  1];
    b = [im_mesh(i, 1);
         im_mesh(i, 2);
             1       ];
    barycentric(i,:) = A \ b;    
end

%% source image: compute corresponding pixel coordinate

im1_crsp = zeros(length(t),2);
for i = 1 : length(t)
    if isnan(t(i))
        % im1_crsp(i,:) = [x(ceil(i/(d(2)+.1)),1) y(1,mod(i-1,d(2))+1)];
        im1_crsp(i,:) = [NaN NaN];
        continue;
    end
    ax = im1_pts(tri(t(i),1), 2);
    bx = im1_pts(tri(t(i),2), 2);
    cx = im1_pts(tri(t(i),3), 2);
    ay = im1_pts(tri(t(i),1), 1);
    by = im1_pts(tri(t(i),2), 1);
    cy = im1_pts(tri(t(i),3), 1);
    A = [ax, bx, cx; ay, by, cy; 1, 1, 1];
    
    X = A * barycentric(i,:)';
    im1_crsp(i,:) = X(1:2) / X(3); % (row col)
end

im2_crsp = zeros(length(t),2);
for i = 1 : length(t)
    if isnan(t(i))
        % im2_crsp(i,:) = [x(ceil(i/(d(2)+.1)),1) y(1,mod(i-1,d(2))+1)];
        im2_crsp(i,:) = [NaN NaN];
        continue;
    end
    ax = im2_pts(tri(t(i),1), 2);
    bx = im2_pts(tri(t(i),2), 2);
    cx = im2_pts(tri(t(i),3), 2);
    ay = im2_pts(tri(t(i),1), 1);
    by = im2_pts(tri(t(i),2), 1);
    cy = im2_pts(tri(t(i),3), 1);
    A = [ax, bx, cx; ay, by, cy; 1, 1, 1];
    
    X = A * barycentric(i,:)';
    im2_crsp(i,:) = X(1:2) / X(3); % (row col)
end

%% copy back the pixel value from source image to target image

x_morph = reshape(im1_crsp(:,1),size(x'))';
x_morph(x_morph > size(x', 2)) = size(x', 2);
y_morph = reshape(im1_crsp(:,2),size(y'))';
im1_morph = zeros(d);
for c = 1 : size(im1, 3)
    im1_morph(:, :, c) = interp2(x', y', double(im1(:, :, c))', x_morph, y_morph);
end
x_morph = reshape(im2_crsp(:,1),size(x'))';
x_morph(x_morph > size(x', 2)) = size(x', 2);
y_morph = reshape(im2_crsp(:,2),size(y'))';
im2_morph = zeros(d);
for c = 1 : size(im2, 3)
    im2_morph(:, :, c) = interp2(x', y', double(im2(:, :, c))', x_morph, y_morph);
end

%% cross-dissolve
morphed_im = (1 - dissolve_frac) * im1_morph + dissolve_frac * im2_morph;
morphed_im = uint8(round(morphed_im));

figure;
imshow(morphed_im)
