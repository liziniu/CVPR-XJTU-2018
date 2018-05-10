function gas = recoverLaplacian(laps)
    f = [1/8, 1/4, 1/4, 1/4, 1/8];
    n = size(laps, 1);
    gas = laps{end, 1};
    for i = n-1 : - 1: 1
        try
            expand_img = expand(gas, f);
            gas = expand_img + laps{i, 1};
        catch
            size(gas)
            size(expand_img)
            size(laps{i-1, 1})
    end
end

