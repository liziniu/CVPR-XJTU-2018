back = imread('back.jpg');
fore = imread('fore.png');
fore = imresize3(fore, [200, 200, 3]);



% function result = gradient_blend(fore, back)
    % 假设前景图比背景图要小
    [h_f, w_f, c_f] = size(fore);
    [h_b, w_b, c_b] = size(back);
    
    % 创建mask
    [center_fore, mask] = create_mask(fore);
    imshow(back);
    [x, y] = ginput(1);
    center_back = [x, y];
    close;
    
    back = double(back);
    fore = double(fore);
    % 求出在背景图中的偏移量
    x_shift = floor(center_back(1) - center_fore(1));    %宽度
    y_shift = floor(center_back(2) - center_fore(2));    %高度
    
    % 挑选出mask变量
    index = find(mask~=0);  % 变量在前景图中的列表示方法
    n = length(index);      % 变量个数
    A = zeros(n, n);       % 系数矩阵
    b = cell(c_f, 1);       % 常数b, 前景图的梯度信息
    res = cell(c_f, 1);     % 线性方程组的解
    for c = 1: c_f         
        b{c, 1} = zeros(n,1);         
    end
    disp(['mask变量个数:', num2str(n)]);
    if n > 25000
        disp('区域太大');
        return;
    end
    
    disp('形成系数矩阵A和b');
    % 形成系数矩阵A和b
    count = 1;
    for i = 1 : w_f
        for j = 1 : h_f
            % 如果是mask中的点
            if mask(j, i)
                for c = 1 : c_f
                    % 前景图的Laplace梯度
                    b{c, 1}(count) = 4*fore(j,i, c)-fore(j-1,i, c)-fore(j+1,i, c)-fore(j,i+1, c)-fore(j,i-1, c);

                    % 计算A阵中的坐标
                    A(count, count) = 4;

                    % A阵中其余4个点[j-1, i], [j+1, i], [j, i-1], [j, i+1],
                    % 需要判断其是否为变量
                    % [j-1, i]
                    if mask(j-1, i) == 1
                        position = (i-1) * h_f + j-1;         %以列向量优先的位置
                        order = find(index == position);      %是第几个变量
                        A(count, order) = -1;
                    else
                        b{c, 1}(count) = b{c, 1}(count) + back(j-1+y_shift, i+x_shift, c);     %边界点
                    end
                    % [j+1, i]
                    if mask(j+1, i) == 1
                        position = (i-1) * h_f + j+1;         
                        order = find(index == position);     
                        A(count, order) = -1;
                    else
                        b{c, 1}(count) = b{c, 1}(count) + back(j+1+y_shift, i+x_shift, c);
                    end
                    % [j, i+1]
                    if mask(j, i+1) == 1
                        position = (i+1-1) * h_f + j;       
                        order = find(index == position);      
                        A(count, order) = -1;
                    else
                        b{c, 1}(count) = b{c, 1}(count) + back(j+y_shift, i+1+x_shift, c);
                    end
                    % [j, i-1]
                    if mask(j, i-1) == 1
                        position = (i-1-1) * h_f + j;         
                        order = find(index == position);     
                        A(count, order) = -1;
                    else
                        b{c, 1}(count) = b{c, 1}(count) + back(j+y_shift, i-1+x_shift, c);
                    end
                end
                count = count + 1;
            end
         end
    end
    
    disp('求解线性方程组');
    % 求解线性方程组
    for c = 1: c_f
        res{c, 1} = sparse(A) \ b{c, 1};
    end
    
    disp('将结果copy到背景图');
    % 将结果copy到背景图
    count = 1;
    for i = 1 : w_f
        for j = 1 : h_f
            if mask(j,i)
                for c = 1: c_f
                    back(j+y_shift, i+x_shift, c) = res{c, 1}(count);
                end
                count = count + 1;
            end
        end
    end
    result = uint8(back);
     
    figure;
    imshow(result);
% end