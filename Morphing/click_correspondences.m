function [im1_pts, im2_pts] = click_correspondences(im1, im2)

% im1: imread('...'), moving image, the 1st image
% im2: imread('...'), fixed image, the 2nd image
% im1_pts: n x 2 double
% im2_pts: n x 2 double

assert(size(im1,3) == 3 & size(im2,3) == 3);
assert(size(im1,1) == size(im2,1) & size(im1,2) == size(im2,2));

[im1_pts, im2_pts] = cpselect(im1, im2, 'Wait', true);

% t_concord = fitgeotrans(im1_pts, im2_pts, 'projective');
% R_im2 = imref2d(size(im2));
% im1_registered = imwarp(im1, t_concord, 'OutputView', R_im2);
% figure; imshowpair(im1_registered, im2, 'blend');

