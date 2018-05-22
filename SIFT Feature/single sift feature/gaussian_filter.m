%% 1Î¬¸ßË¹ÂË²¨Æ÷
function g = gaussian_filter(size, sigma)
    h = fspecial('gaussian', size, sigma);
    g = h(1, :);
    g = g ./ sum(g);
end