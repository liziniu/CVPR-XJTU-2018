function [img_p] = stitch(img1, img2,img3, h1, h3)
%% 根据单应矩阵h,将imag1, img3转换到img2, 维持img2的h不变
% img1: left
% img2: center
% img3: right
% h1: left->center
% h3: right->center
% h * [x; y; 1]

if size(h1, 1) ~= 3 || size(h1, 2) ~= 3
    error('h should be 3x3');
end
if size(h3, 1) ~= 3 || size(h3, 2) ~= 3
    error('h should be 3x3');
end

img1 = double(img1); img2 = double(img2); img3 = double(img3);

h_1 = size(img1, 1); w_1 = size(img1, 2);
h_3 = size(img3, 1); w_3 = size(img3, 2);
h_2 = size(img2, 1); w_2 = size(img2, 2); c_2 = size(img2, 3);

%{
% 根据边界求解需要增加的边界
x1_bound = [1, w1,  w1,  1;
            1,  1,  h1, h1;
            1,  1,   1,  1];
x3_bound = [1, w3,  w3,  1;
            1,  1,  h3, h3;
            1,  1,   1,  1];
x1_bound_t = h1 * x1_bound; x3_bound_t = h3 * x3_bound;  % 3x4
% 转化为齐次坐标
x1_bound_t = [x1_bound_t(1, :) ./ x1_bound_t(3, :);      % 2x4
              x1_bound_t(2, :) ./ x1_bound_t(3, :);]    
x3_bound_t = [x3_bound_t(1, :) ./ x3_bound_t(3, :);      % 2x4
              x3_bound_t(2, :) ./ x3_bound_t(3, :);]
%}

h_p = h_2; w_p = w_2 * 2;
if c_2 == 1
    img_p = zeros(h_p, w_p, 1);
else
    img_p = zeros(h_p, w_p, c_2);
end

% 将img2置于中心
img_p(:, 0.5*w_2:1.5*w_2-1, :) = img2(:, :, :);

figure;
imshow(uint8(img_p));
% 前向变换
for j = 1: h_1
    for i = 1: w_1
        x1 = [i; j; 1];                         % 3x1
        x1_t = h1 * x1;                         % 3x1
        x1_t = [x1_t(1, :) ./ (x1_t(3, :)+1e-10);       % 
                x1_t(2, :) ./ (x1_t(3, :)+1e-10)];      % 2x1
        x1_t = x1_t + [0.5*w_2; 0];
        x1_x = int32(round(x1_t(1, 1))); x1_y = int32(round(x1_t(2, 1)));

        if x1_x > 0 && x1_x < w_p && x1_y > 0 && x1_y < h_p
            if img_p(x1_y, x1_x, 1) ~= 0
                img_p(x1_y, x1_x, :) = 0.5*img_p(x1_y, x1_x, :) + 0.5*img1(j, i, :);
            else
                img_p(x1_y, x1_x, :) = img1(j, i, :);
            end
        else
            continue
        end
    end
end

figure;
imshow(uint8(img_p));

% 最近邻的差值

for j = 1: h_3
    for i = 1: w_3
        x3 = [i; j; 1];                                    % 3x1
        x3_t = h3 * x3;                                    % 3x1
        x3_t = [x3_t(1, :) ./ (x3_t(3, :)+1e-10);          % 
                x3_t(2, :) ./ (x3_t(3, :)+1e-10)];         % 2x1
        x3_t = x3_t + [0.5*w_2; 0];
        x3_x = int32(round(x3_t(1, 1))); x3_y = int32(round(x3_t(2, 1)));
        if x3_x > 0 && x3_x < w_p && x3_y > 0 && x3_y < h_p
            if img_p(x3_y, x3_x, 1) ~= 0
                img_p(x3_y, x3_x, :) = 0.5*img_p(x3_y, x3_x, :) + 0.5*img3(j, i, :);
            else
                img_p(x3_y, x3_x, :) = img3(j, i, :);
            end
        else
            continue
        end
    end
end


% 双线性的插值
%{
for j = 1: h_3
    for i = 1: w_3
        x3 = [i; j; 1];                                    % 3x1
        x3_t = h3 * x3;                                    % 3x1
        x3_t = [x3_t(1, :) ./ (x3_t(3, :)+1e-10);          % 
                x3_t(2, :) ./ (x3_t(3, :)+1e-10)];         % 2x1
        x3_t = x3_t + [0.5*w_2; 0];
        x3_x = x3_t(1, 1); x3_y = x3_t(2, 1);
        xlo = floor(x3_x); ylo = floor(x3_y); xhi = ceil(x3_x); yhi = ceil(x3_y);
        delta_x = x3_x - xlo; delta_y = x3_y - ylo;
        % 左上角
        if xlo > 0 && xlo < w_p && ylo > 0 && ylo < h_p
            if img_p(ylo, xlo, 1) == 0
                img_p(ylo, xlo, :) = img3(j, i, :) * (1 - delta_x) * (1 - delta_y);
            else
                img_p(ylo, xlo, :) = 0.5 * img_p(ylo, xlo, :) + 0.5 * img3(j, i, :) * (1 - delta_x) * (1 - delta_y);
            end
        end
        % 右上角
        if xhi > 0 && xhi < w_p && ylo > 0 && ylo < h_p
            if img_p(ylo, xhi, 1) == 0
                img_p(ylo, xhi, :) = img3(j, i, :) * delta_x * (1 - delta_y);
            else
                img_p(ylo, xhi, :) = 0.5 * img_p(ylo, xhi, :) + 0.5 * img3(j, i, :) * delta_x * (1 - delta_y);
            end
        end
        % 左下角
        if xlo > 0 && xlo < w_p && yhi > 0 && yhi < h_p
            if img_p(yhi, xlo, 1) == 0
                img_p(yhi, xlo, :) = img3(j, i, :) * (1 - delta_x) * delta_y;
            else
                img_p(yhi, xlo, :) =  0.5 * img_p(yhi, xlo, :) + 0.5 * img3(j, i, :) * (1 - delta_x) * delta_y;
            end
        end
        % 右下角
        if xhi > 0 && xhi < w_p && yhi >0 && yhi < h_p
            if img_p(yhi, xhi, 1) == 0
                img_p(yhi, xhi, :) = img3(j, i, :) * delta_x * delta_y;
            else
                img_p(yhi, xhi, :) = 0.5 * img_p(yhi, xhi, :) +  0.5 * img3(j, i, :) * delta_x * delta_y;
            end
        end
    end
end     
%}     

% fill the 0
%{
for i = 1:length(x)
    count = 0;
    ix = x(i);
    iy = y(i);
    try
        if img_p(iy, ix+1, 0) ~= 0
            img_p(iy, ix, :) = img_p(iy, ix, :) + img_p(iy, ix+1, :);
            count = count + 1;
        end
    catch
    end
    try
        if img_p(iy, ix-1, 0) ~= 0
            img_p(iy, ix, :) = img_p(iy, ix, :) + img_p(iy, ix-1, :);
            count = count + 1;
        end
    catch
    end
    if count ~= 0
        img_p(j, i, :) = img_p(j, i, :) ./ count;
    else
    end
end
%}


img_p = uint8(img_p);

figure;
imshow(img_p);

end