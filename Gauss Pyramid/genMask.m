
% 读入一幅图像，利用Matlab的roipoly函数标记一个多边形的区域
im1 = imread('fore.png'); 


% 利用roipoly从图片1中选择感兴趣区域
figure(1);clf; %imshow(im1);
[BW, xi, yi] = roipoly(im1);
save('cat.mat','BW','xi','yi');