%% Expand 操作
function res = expand(img, f)
    [h, w, c] = size(img);
    res = zeros(2*h, 2*w, c);
    temp = zeros(h, 2*w, c);   % 第一次扩展后的临时图像
    size_filter = size(f);
    n_f = size_filter(2);
    % 横向扩展
    %{
      3:[1, 2, 3, 4, 5]->[2, 3, 4, 5, 6]->[1, 1.5, 2, 2.5, 3]->[1, 2, 3]
      4:[2, 3, 4, 5, 6]->[3, 4, 5, 6, 7]->[1.5, 2, 2.5, 3, 3.5]->[2, 3]
    %}
    for i = 1: w*2
        for j = 1: h
            p = [];
            for n = -(n_f - 1)/2 : (n_f - 1)/2
                p = [p; get_point(img, j, (i+n)/2, c)];
            end
            if 0
                i, j, p
            end 
            temp(j, i, :) = 2 * f * p;
        end
    end
    % 纵向扩展
    for i = 1: 2*w
        for j = 1: 2*h
            p = [];
            for n = -(n_f - 1)/2 : (n_f - 1)/2
                p = [p;get_point(temp, (j+n)/2, i, c)];
            end
            res(j, i, :) = 2 * f * p;
        end
    end
end