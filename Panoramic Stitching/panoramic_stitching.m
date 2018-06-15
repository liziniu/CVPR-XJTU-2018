function [img_p] = panoramic_stitching(img1, img2, img3, shrink)
%% 3幅全景拼接 
% img1: left img
% img2: center img
% img3: right img
% shrink: true or false(default: true), whether shrink images to speed up

if ~exist('shrink', 'var')
    shrink = true;
    s = 700;
end

%% Check size
if shrink
    [h_1, w_1, c_1] = size(img1);[h_2, w_2, c_2] = size(img2); [h_3, w_3, c_3] = size(img3);
    if h_1 > s || w_1 > s
        if h_1 > w_1
            img1 = imresize3(img1, [s, round(s*w_1/h_1), c_1]);
        else
            img1 = imresize3(img1, [round(s*h_1/w_1), s, c_1]);
        end
    end
    if h_2 > s || w_2 > s
        if h_2 > w_2
            img2 = imresize3(img2, [s, round(s*w_2/h_2), c_2]);
        else
            img2 = imresize3(img2, [round(s*h_2/w_2), s, c_2]);
        end
    end
    if h_3 > s || w_3 > s
        if h_3 > w_3
            img3 = imresize3(img3, [s, round(s*w_3/h_3), c_3]);
        else
            img3 = imresize3(img3, [round(s*h_3/w_3), s, c_3]);
        end
    end
end
%% surf特征匹配及估计单应矩阵
[l1, l2, index_pairs] = match_surf(img2, img1);
h1 = ransac(l1, l2, index_pairs)
[l1, l2, index_pairs] = match_surf(img2, img3);
h3 = ransac(l1, l2, index_pairs)
%% 图像拼接
img_p = stitch(img1, img2, img3, h1, h3);
