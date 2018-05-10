
%% test module
%{
clear;clc;
%img = imread('/Users/liziniu/documents/girl2.jpeg');
img = imread('background.jpg');
reduced_img = reduce(img, [1/8, 1/4, 1/4, 1/4, 1/8]);
figure(1);
subplot(1, 2, 1);
imshow(img);
subplot(1, 2, 2);
imshow(uint8(reduced_img));

clear;clc;
img = imread('/Users/liziniu/documents/girl2.jpeg');
nlvls = 2;
res = genPyramids(img, nlvls);
figure(1);
count = 1;
for i = 1: nlvls
    for j = 1:2
        subplot(nlvls, j, count)
        count = count + 1;
        imshow(res{i, j});
    end
end
%}
%% Laplace金字塔的生成
function laps1 = genPyramids(im1, nlvls)
    w = [1/8 1/4 1/4 1/4 1/8];
    if size(im1, 3) == 1
        [h, w] = size(im1);
        im1 = reshape(im1, [h,w,1]);
    end
    laps1 = cell(nlvls,2); 
    laps1{1,1} = double(im1);
    for i = 2 : nlvls
        laps1{i,1} = reduce(laps1{i-1,1},w);
    end
    laps1{end,2} = laps1{end,1};
    for i = nlvls-1 : -1 : 1
        temp = expand(laps1{i+1,1},w);
        expSize = size(temp);
        orgSize = size(laps1{i,1});
        if(expSize(1) < orgSize(1))
            temp = vertcat(temp, temp(end,:,:));     % 确保在基数情况下成立
        end
        if(expSize(2) < orgSize(2))
           temp =  horzcat(temp, temp(:,end,:));
        end
        laps1{i,2} = laps1{i,1} - temp;              % Laplace金字塔
    end
end