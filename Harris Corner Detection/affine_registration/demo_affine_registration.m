
%% 锟斤拷取锟斤拷锟斤拷图锟斤拷
im1 = imresize3(imread('pic1.jpg'), [600, 800, 3]);
im2 = imresize3(imread('pic2.jpg'), [600, 800, 3]);
figure(1);clf; imshow(cat(2, im1,im2));

%% 锟斤拷锟斤拷ginput锟斤拷取锟斤拷锟斤拷锟斤拷
if(0)
%if(exist('leftpoints.mat','file') && exist('rightpoints.mat','file'))
    left = load('leftpoints.mat');
    xsLeft = left.xsLeft; ysLeft = left.ysLeft;
    right = load('rightpoints.mat');
    xsRight = right.xsRight; ysRight = right.ysRight;
    
    figure(1); hold on;
    plot(xsLeft, ysLeft,'rx','markersize',15);
    for i = 1 : length(xsLeft)
        str = [num2str(i),':(',num2str(xsLeft(i)),', ', num2str(ysLeft(i)), ')']; 
       text(xsLeft(i), ysLeft(i), str, 'fontsize', 15, 'color', 'r') ;
    end
    plot(xsRight + size(im1,2), ysRight,'rs','markersize',15);
    for i = 1 : length(xsRight)
        str = [num2str(i),':(',num2str(xsRight(i)),', ', num2str(ysRight(i)), ')']; 
       text(xsRight(i) + size(im1,2), ysRight(i), str, 'fontsize', 15, 'color', 'r') ;
    end    
    
else
    [xsLeft, ysLeft] = ginput(3);
    xsLeft = round(xsLeft);
    ysLeft = round(ysLeft);
    figure(1); hold on;
    plot(xsLeft, ysLeft,'rx','markersize',15);
    for i = 1 : length(xsLeft)
        str = [num2str(i),':(',num2str(xsLeft(i)),', ', num2str(ysLeft(i)), ')']; 
       text(xsLeft(i), ysLeft(i), str, 'fontsize', 15, 'color', 'r') ;
    end


    [xsRight, ysRight] = ginput(3);
    xsRight = round(xsRight);
    ysRight = round(ysRight);
    figure(1); hold on;
    plot(xsRight, ysRight,'rs','markersize',15);
    for i = 1 : length(xsRight)
        str = [num2str(i),':(',num2str(xsRight(i)-size(im1,2)),', ', num2str(ysRight(i)), ')']; 
       text(xsRight(i), ysRight(i), str, 'fontsize', 15, 'color', 'r') ;
    end
    
    xsRight = xsRight - size(im1,2);
    save('leftpoints.mat','xsLeft','ysLeft');
    save('rightpoints.mat', 'xsRight', 'ysRight');
end

% 锟斤拷锟斤拷图锟斤拷
cdata = print('-RGBImage');
imwrite(cdata, 'concatenate.png');

%% 锟斤拷锟斤拷锟斤拷训姆锟斤拷锟戒换
% 锟斤拷锟揭边的碉拷通锟斤拷锟斤拷锟斤拷浠伙拷浠伙拷锟斤拷锟斤拷
npoints = length(xsRight); 
onevec = ones(npoints,1);
zeromat = zeros(npoints,3);

% 濉???A??b 
A = [xsRight(1), ysRight(1), 1, 0, 0, 0;
     0, 0, 0, xsRight(1), ysRight(1), 1;
     xsRight(2), ysRight(2), 1, 0, 0, 0;
     0, 0, 0, xsRight(2), ysRight(2), 1;
     xsRight(3), ysRight(3), 1, 0, 0, 0;
     0, 0, 0, xsRight(3), ysRight(3), 1;];
b = [xsLeft(1);ysLeft(1);xsLeft(2);ysLeft(2);xsLeft(3);ysLeft(3);];

x = A\b;

%% 锟斤拷锟狡第讹拷锟斤拷图锟斤拷谋呖锟斤拷诘锟揭伙拷锟酵硷拷锟斤拷械谋浠伙拷锟斤拷锟?
nx2 = size(im2,2); ny2 = size(im2,1);
xsbound2 = [1 nx2 nx2 1];
ysbound2 = [1 1 ny2 ny2];
Aff = [x(1:3)'; x(4:6)'];

% Aff
% [a11 a12 b1;
%  a21 a22 b2;]

% [1 nx2 nx2  1;
%  1  1  ny2 ny2;
%  1  1   1   1;]

x2bound_transformed = Aff * [xsbound2;ysbound2;ones(1,4)];    % im2的四个顶点仿射变换后的坐标
% [2, 4]

% 四个仿射变换后的点组成的四边形边框
figure(1); hold on;
plot([x2bound_transformed(1,:) x2bound_transformed(1,1)],...
     [x2bound_transformed(2,:) x2bound_transformed(2,1)],'r-');
 

% 锟斤拷锟斤拷铣锟斤拷锟斤拷锟斤拷锟狡?
nx1 = size(im1,2); ny1 = size(im1,1);
xlo = min([1 x2bound_transformed(1,:)]); xlo = floor(xlo);
xhi = max([nx1 x2bound_transformed(1,:)]); xhi = ceil(xhi);
ylo = min([1 x2bound_transformed(2,:)]); ylo = floor(ylo);
yhi = max([ny1 x2bound_transformed(2,:)]); yhi = ceil(yhi);

%%
% 锟斤拷录锟斤拷锟斤拷锟竭匡拷
bounds = cell(2,4);
bounds{1,1} = [1 nx1 nx1 1;1 1 ny1 ny1] + repmat([-xlo+1;-ylo+1],[1 4]);
% [1 nx1 nx1  1;        [-xlo+1; -xlo+1; -xlo+1; -xlo+1;      [xlo, nx1+xlo-1, nx1+xlo-1,    xlo 
%  1  1  ny1 ny1;]  -   [-ylo+1; -ylo+1; -ylo+1; -ylo+1;]  =   ylo,     ylo,   ny1+ylo-1, ny1+ylo-1]
bounds{2,1} = x2bound_transformed + repmat([-xlo+1;-ylo+1],[1 4]);

bounds{1,2} = [1 0 -xlo+1; 0 1 -ylo+1];
bounds{2,2} = Aff; bounds{2,2}(:,3) = bounds{2,2}(:,3) - [-xlo+1;-ylo+1];

% 锟斤拷锟斤拷Mask锟斤拷息
sigma = 0.75;
[xg1,yg1] = meshgrid(1:nx1, 1:ny1); 
mask1 = (xg1 - nx1/2.0).^2 ./(sigma*nx1)^2 + (yg1 - ny1/2.0).^2./(sigma*ny1)^2;
[xg2,yg2] = meshgrid(1:nx2, 1:ny2);
mask2 = (xg2 - nx2/2.0).^2 ./(sigma*nx2)^2 + (yg2 - ny2/2.0).^2./(sigma*ny2)^2;

bounds{1,3} = exp(-mask1);
bounds{2,3} = exp(-mask2);

bounds{1,4} = im1;
bounds{2,4} = im2;

%% 锟斤拷锟斤拷图锟斤拷暮喜锟?
nc = size(im1,3);
imTotal = zeros(yhi-ylo+1, xhi-xlo+1, nc);

% 锟斤拷锟揭伙拷锟?Mask
maskTotal = zeros(yhi-ylo+1, xhi-xlo+1);

% 锟斤拷始挪锟斤拷图锟斤拷锟斤拷锟斤拷
figure(2);clf; imshow(uint8(imTotal));
hold on;
for i = 1 : 2
   plot([bounds{i,1}(1,:) bounds{i,1}(1,1)],...
        [bounds{i,1}(2,:) bounds{i,1}(2,1)], 'r-');
    
   xlo_i = floor(min(bounds{i,1}(1,:)));
   xhi_i = ceil(max(bounds{i,1}(1,:)));
   ylo_i = floor(min(bounds{i,1}(2,:)));
   yhi_i = ceil(max(bounds{i,1}(2,:)));
   
   [xg_i,yg_i] = meshgrid(xlo_i:xhi_i,ylo_i:yhi_i);
   
   Aff = bounds{i,2};
   coords_i = inv(Aff(1:2,1:2)) * ([xg_i(:) yg_i(:)]' - repmat(Aff(:,3),[1, numel(xg_i)]));
 
   xcoords_i = reshape(coords_i(1,:), size(xg_i));
   ycoords_i = reshape(coords_i(2,:), size(xg_i));
   
   im_i = zeros(yhi_i-ylo_i+1, xhi_i-xlo_i+1,nc);
   for j = 1 : nc
    im_i(:,:,j) = interp2(double(bounds{i,4}(:,:,j)), xcoords_i, ycoords_i, 'linear', 0);
   end
   mask_i = interp2(bounds{i,3}, xcoords_i, ycoords_i, 'linear', 0);
   figure(3);imshow(uint8(im_i));
   figure(4);imagesc(mask_i);
   
   imTotal(ylo_i:yhi_i, xlo_i:xhi_i, :) = imTotal(ylo_i:yhi_i, xlo_i:xhi_i, :)  + im_i .* repmat(mask_i, [1 1 nc]);
   maskTotal(ylo_i:yhi_i, xlo_i:xhi_i) = maskTotal(ylo_i:yhi_i, xlo_i:xhi_i) + mask_i;
end

imTotal = imTotal./repmat(maskTotal+1e-20,[1 1,3]);
figure(5); imshow(uint8(imTotal));
% 锟斤拷锟斤拷图锟斤拷
cdata = print('-RGBImage');
imwrite(cdata, 'merged_img.png');
