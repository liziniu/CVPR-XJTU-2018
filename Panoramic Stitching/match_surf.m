function [location1, location2, index_pairs] = match_surf(img1, img2)
%  提取surf特征，进行匹配，返回特征点的坐标，以及匹配的点对
if size(img1, 3) == 3
    img1 = rgb2gray(img1);
end
if size(img2, 3) == 3
    img2 = rgb2gray(img2);
end

points1 = detectSURFFeatures(img1);  
points2 = detectSURFFeatures(img2);   

location1 = points1.Location;
location2 = points2.Location;
%Extract the features.计算描述向量  
[f1, vpts1] = extractFeatures(img1, points1);  
[f2, vpts2] = extractFeatures(img2, points2);  


%Retrieve the locations of matched points. The SURF feature vectors are already normalized.  
%进行匹配  
index_pairs = matchFeatures(f1, f2, 'Unique', true);
matchedPoints1 = vpts1(index_pairs(1:20, 1));
matchedPoints2 = vpts2(index_pairs(1:20, 2));
figure; ax = axes;
showMatchedFeatures(img1,img2,matchedPoints1,matchedPoints2,'montage','Parent',ax);
title(ax, 'Candidate point matches');
legend(ax, 'Matched points 1','Matched points 2');
end