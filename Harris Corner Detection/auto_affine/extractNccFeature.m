function descps = extractNccFeature(img, Locs, halfsz)

% parse the input parameters
if(~exist('halfsz','var'))
   halfsz = [12,12];
else
    if(length(halfsz) <= 1)
        halfsz = [halfsz, halfsz];
    else
        halfsz = halfsz(1:2);
    end
end
halfsz = round(halfsz);
halfsz(halfsz<1) = 1;

%% 特征点提取

nc = size(img,3);
dim = prod(2*halfsz+1);             % (12*2+1) * (12*2+1) = 625
descps = zeros(size(Locs,1), nc * dim);  % (470, 1875) 470个特征点， 625*3

img = double(img);

for i = 1 : size(Locs,1)        % 470个角点
    x = Locs(i,1);
    y = Locs(i,2);
    
    xlo = max([1, x - halfsz(1)]);
    xhi = min([size(img,2), x + halfsz(1)]);
    ylo = max([1, y - halfsz(2)]);
    yhi = min([size(img,1), y + halfsz(2)]);
    
    count = (xhi - xlo + 1) * (yhi - ylo + 1);
    data = img(ylo:yhi, xlo:xhi);
    descps(i, 1:count) = data(:); 
end

% do the normalization
descps = descps - repmat(mean(descps,2),[1 nc * dim]);       % 最终效果： descps每个都减mean
descps = descps ./ repmat(sqrt(sum(descps.^2,2)+1e-20),[1 nc*dim]);
end