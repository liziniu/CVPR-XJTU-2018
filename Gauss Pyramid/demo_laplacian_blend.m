clear; clc;
% demo_laplacian_blend 
% 读入两幅照片，以及采用genMask标记的图像区域
imA = imread('fore.png');  
maskA = load('cat.mat', 'BW');  maskA = maskA.BW; maskA = double(maskA); % BW为poi的二维矩阵逻辑值，包含poi的点为true
imB = imread('back.png');  

%% padding 使得两幅图的大小一致
% % 灰度图情况下szA和szB的第三个维度要为1
szA = size(imA); if(size(imA,3) == 1), szA(3) = 1; end     
szB = size(imB); if(size(imB,3) == 1), szB(3) = 1; end
sz = max([szA(:) szB(:)],[],2);

%通过padding，将两幅照片的大小实现一致了
% 对图像A和模板maskA进行Padding
if(szA(1) < sz(1))
    imA_pad = vertcat(imA, zeros(sz(1)-szA(1), szA(2), szA(3)));
    maskA_pad = vertcat(maskA, zeros(sz(1) - szA(1), szA(2)));
else
    imA_pad = imA;
    maskA_pad = maskA;
end
if(szA(2) < sz(2))
   imA_pad =  horzcat(imA_pad, zeros(size(imA_pad,1), sz(2) - szA(2), szA(3)));
   maskA_pad = horzcat(maskA_pad, zeros(size(imA_pad,1), sz(2) - szA(2)));
end
if(szA(3) < sz(3))
    imA_pad = repmat(imA_pad,[1 1 3]);
end

% 对图像B进行Padding
if(szB(1) < sz(1))
    imB_pad = vertcat(imB, zeros(sz(1)-szB(1), szB(2), szB(3)));
else
    imB_pad = imB;
end
if(szB(2) < sz(2))
   imB_pad =  horzcat(imB_pad, zeros(size(imB_pad,1), sz(2) - szB(2), szB(3)));
end
if(szB(3) < sz(3))
    imB_pad = repmat(imB_pad,[1 1 3]);
end

%%
% 获取一个位置信息
figure(1);imshow(uint8(imB_pad)); title('imB pad to get the center point');
[xshift,yshift] = ginput(1); 

% 获取原始图像中
maskPoints = load('cat.mat', 'xi', 'yi');
xshift = (xshift - mean(maskPoints.xi));
yshift = (yshift - mean(maskPoints.yi));

% 将图像A和它的模板都进行平移
imA_pad = imtranslate(imA_pad, [xshift, yshift]);
maskA_pad = imtranslate(maskA_pad, [xshift, yshift]);

figure;imshow(uint8(imA_pad));title('imA pad after translate');
figure;imshow(uint8(maskA_pad)*255);('maskA pad after translate');

%%
% 进行拉普拉斯金字塔的分解
nlvls = 3;
lapsA = genPyramids(imA_pad, nlvls);
lapsB = genPyramids(imB_pad, nlvls);

% 将Mask进行imresize运算
lapsMask = genPyramids(maskA_pad, nlvls);

%%
% 通过拉普拉斯金字塔进行合成
lapsBlend = lapsB;
for i = nlvls : -1 : 1
    lapsBlend{i,2} = lapsA{i,2} .* repmat(lapsMask{i,1}, [1 1 sz(3)]) + ...
                     lapsB{i,2} .* (1 - repmat(lapsMask{i,1}, [1 1 sz(3)]));
end

% 通过合成的拉普拉斯金字塔进行恢复
imBlend = recoverLaplacian(lapsBlend(:,2));
figure;imshow(uint8(imBlend));title('Blended Image');