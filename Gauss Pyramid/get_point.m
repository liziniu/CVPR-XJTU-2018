%% Ã·»°µ„
function res = get_point(img, j, i, c)
    try
        res = double(reshape(img(j, i, :), [1,c]));
    catch
        res = double(zeros(1, c));
    end
end