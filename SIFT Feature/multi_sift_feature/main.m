clear; clc;
img = imread('einstein.png');
if size(img, 3) == 3
    img = rgb2gray(img);
end

name = 'my_sift';
octaves = 3;
res = cell(octaves, 4);

% pre blur
initial_sigma = sqrt(2);
[X, Y] = meshgrid(1::sz(2), 1:subsample(octave):sz(1));
g = gaussian_filter(initial_sigma);
signal = conv2(g, g, img, 'same');
subsample = [1];

for octave = 1 : octaves
   fprintf(2, num2str(octave));
   
   % subsample
   sz = size(signal);
   [X, Y] = meshgrid(1:subsample(octave):sz(2), 1:subsample(octave):sz(1));
   signal = uint8(interp2(double(signal), X, Y, 'linear')); 
   subsample = [subsample, subsample(end)*2];
   
   [pos, orient, scale, desc] = Sift1Scale(signal, name, initial_sigma);
   res{octave, 1} = pos;
   res{octave, 2} = orient;
   res{octave, 3} = scale;
   res{octave, 4} = desc;
   
   % filter
   g = gaussian_filter(sigma);
   signal = conv2(g, g, signal, 'same');
   sigma = sigma * subsample(octave+1);
end
