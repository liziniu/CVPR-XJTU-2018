img = imresize3(imread('pic.png'), [1000, 1000, 3]);
corn_thresh = 0.18;
interactive = 1;

% function [locs,cornerness] = detHarrisCorners(img, corn_thresh, interactive)
%% parse the parameters
if(~exist('corn_thresh','var'))
    corn_thresh = 0.01;
end

if(~exist('interactive','var'))
    interactive = 0;
end

if(size(img,3)>1)
    img = rgb2gray(img);
end


%%
[nr,nc] = size(img);

%Filter for horizontal and vertical direction
fx = [1, 0, -1];
fy = [1; 0; -1];

% Convolution of image with dx and dy
Ix = conv2(img, fx, 'same');
Iy = conv2(img, fy, 'same');

if(interactive)
    figure(1); % imagesc 对图像进行缩放后显示
    subplot(1,2,1); imagesc(Ix); axis equal image off; colormap('gray'); title('Ix');
    subplot(1,2,2); imagesc(Iy); axis equal image off; colormap('gray'); title('Iy');
    cdata = print('-RGBImage');
    %imwrite(cdata, fullfile('corner', [name, '-grad.png']));
    imwrite(cdata, '/Users/liziniu/Downloads/计算机视觉与模式识别/角点检测/affine_transform/corner/grad.png');
end

%% Raw Hessian Matrix
% Hessian Matrix Ixx, Iyy, Ixy
Ixx = Ix.*Ix;
Ixy = Ix.*Iy;
Iyy = Iy.*Iy;

if(interactive)
    figure(2); title('Before Smoothing');
    subplot(2,2,1); imagesc(Ixx); axis equal image off; colormap('gray'); title('Ixx');
    subplot(2,2,2); imagesc(Ixy); axis equal image off; colormap('gray'); title('Ixy');
    subplot(2,2,3); imagesc(Ixy); axis equal image off; colormap('gray'); title('Ixy');
    subplot(2,2,4); imagesc(Iyy); axis equal image off; colormap('gray'); title('Ixy');
    cdata = print('-RGBImage');
    %imwrite(cdata, fullfile('corner', [name, '-rawHessian.png']));
    imwrite(cdata, '/Users/liziniu/Downloads/计算机视觉与模式识别/角点检测/affine_transform/corner/rawHessian.png');
end

%% Gaussian filter definition (https://en.wikipedia.org/wiki/Canny_edge_detector)
G = [2, 4, 5, 4, 2; 4, 9, 12, 9, 4;5, 12, 15, 12, 5;4, 9, 12, 9, 4;2, 4, 5, 4, 2];
G = 1/159.* G;

% Convolution with Gaussian filter
Ixx = conv2(Ixx, G, 'same');
Ixy = conv2(Ixy, G, 'same');
Iyy = conv2(Iyy, G, 'same');

if(interactive)
    figure(3); title('After Smoothing');
    subplot(2,2,1); imagesc(Ixx); axis equal image off; colormap('gray'); title('Ixx');
    subplot(2,2,2); imagesc(Ixy); axis equal image off; colormap('gray'); title('Ixy');
    subplot(2,2,3); imagesc(Ixy); axis equal image off; colormap('gray'); title('Ixy');
    subplot(2,2,4); imagesc(Iyy); axis equal image off; colormap('gray'); title('Iyy');
    cdata = print('-RGBImage');
    %imwrite(cdata, fullfile('corner', [name, '-smoothHessian.png']));
    imwrite(cdata, '/Users/liziniu/Downloads/计算机视觉与模式识别/角点检测/affine_transform/corner/smoothHessian.png');
end

%%
% calculate the lambda1 and lambda2
%{
if(interactive)
    delta = (Ixx + Iyy).^2 - 4 * 1 * (Ixx.*Iyy - Ixy .* Ixy);
    lambda1 = 0.5 * ((Ixx + Iyy) + sqrt(delta));
    lambda2 = 0.5 * ((Ixx + Iyy) - sqrt(delta));
    figure(6); 
    subplot(1,2,1); imagesc(lambda1); axis equal image off; colormap('gray'); title('\lambda_1');
    subplot(1,2,2); imagesc(lambda2); axis equal image off; colormap('gray'); title('\lambda_2');
end
%}
%%
% Calculate the corner responseling'luan
k = 0.05; % usually in the range[0.04 0.06]

% R = lambda1.*lambda2 - k*(lambda1 + lambda2).^2;


f = @(M) det(M) - k*trace(M)
R = zeros(nr, nc);
for j = 1:nr
    for i = 1: nc
        R(j, i) = f([Ixx(j, i), Ixy(j, i);
                     Ixy(j, i), Iyy(j, i);]);
    end
end
rmax = max(R(:)); % get the maximum response of the cornerness

corner = zeros(nr,nc);
for j = 1:nr
    for i = 1:nc
        count = 0;
        for u = -1 : 1
            for v = -1 : 1
                try
                    if R(j, i) >= R(j+u, i+v)
                       count = count + 1;
                    end
                catch
                end
            end
        end
        if count == 9
            corner(j, i) = 1;
        else
            corner(j, i) = 0;
        end
    end
end

if(interactive)
    figure(4); 
    subplot(1,2,1); imagesc(R); title('Before Non-Local Maximum Suppression');axis equal image off; colormap('gray');

    subplot(1,2,2); imagesc(R .* corner); title('After Non-Local Maximum Suppression');axis equal image off; colormap('gray');
    cdata = print('-RGBImage');
    %imwrite(cdata, fullfile('corner', [name, '-cornerness.png']));
    imwrite(cdata, '/Users/liziniu/Downloads/计算机视觉与模式识别/角点检测/affine_transform/corner/cornerness.png');
end

[iLoc, jLoc] = find(R.*corner > corn_thresh * rmax);

if(interactive)
    figure(5); imagesc(img); hold on; axis equal image off; colormap('gray');
    for i = 1 : length(iLoc)
        plot(jLoc(i), iLoc(i), 'rx');
    end
    hold off;
    cdata = print('-RGBImage');
    %imwrite(cdata, fullfile('corner', [name, '-corners.png']));
    imwrite(cdata, '/Users/liziniu/Downloads/计算机视觉与模式识别/角点检测/affine_transform/corner/corners.png');
end

% assign the output variables
locs = [jLoc iLoc];
cornerness = R(sub2ind(size(R),iLoc,jLoc));