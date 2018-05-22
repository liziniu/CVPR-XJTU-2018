
% sift key point detection ------- 1 octave case
im = imread('girl.jpg');
if(size(im,3) == 3)
    im = rgb2gray(im);
end
im = im2double(im);

[pos, orient, scale, desc] = Sift1Scale(im, 'girl');

% 
figure;imshow(im); hold on;
quiver(pos(:,1),pos(:,2), cos(orient), sin(orient), 0.5,'linewidth',2);
plot(pos(:,1), pos(:,2), 'r+','markersize',12);
hold off;
cdata = print('-RGBImage');
imwrite(cdata, fullfile(['einstein','-direction.png']));