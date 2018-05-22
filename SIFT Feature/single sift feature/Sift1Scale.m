%% sift特征提取流程
% 1.序列号的高斯滤波
% 2.高斯差分得到拉普拉斯图像
% 3.求解拉普拉斯图像的尺度、空点不变点
% 4.根据梯度直方图估计像素点的方向
% 5.根据像素点的方向，求解8*8方向内(4*4)*8维的特征向量
% 6.特征匹配
% im = imread('einstein.png');we

function [pos, orient, scale, desc] = Sift1Scale(im, name)
% parse the parameters
if(~exist('name','var'))
    name = 'sift';
end

%%

% define the scales in one octave
o = 1; % just 1 octave for illustration
s = 4;
k = 2^(1/s);
nGau = s + 3;
nDog = s + 2;

% define the sigma
octave = o; % clamp the octave to 1

absolute_sigma = zeros(octave, s+3);          % s+3=7  % s个特征点，需要s+2个拉普拉斯，需要s+3个高斯
filter_size = zeros(octave, s+3);
filter_sigma = zeros(octave, s+3);
gauss_pyr = cell(octave, s+3);
DOG_pyr = cell(octave);                       

initial_sigma = sqrt(2);
absolute_sigma(octave, 1) = initial_sigma;

%%
% do the progressive bluring
sigma = initial_sigma;
hsize = 5;
g = gaussian_filter(hsize, sigma);
filter_size(octave, 1) = length(g);
filter_sigma(octave, 1) = sigma;
gauss_pyr{octave,1} = conv2(g, g, im, 'same');
DOG_pyr{octave} = zeros(size(gauss_pyr{octave,1}, 1),size(gauss_pyr{octave,1},2),s+2);

% Get the DoG and Gaussian Pyramid
for interval = 2:(s+3)
    % get the kernel size for the progressive blurring
      sigma_f = sqrt(k^2 - 1)*sigma;
      g = gaussian_filter(hsize, sigma_f);
      sigma = k*sigma;
      
      % Keep track of the absolute sigma
      absolute_sigma(octave,interval) = sigma;
      
      % Store the size and standard deviation of the filter for later use
      filter_size(octave,interval) = length(g);
      filter_sigma(octave,interval) = sigma;
      
      % Get the Gaussian Pyramid
      gauss_pyr{octave,interval} = conv2(g, g, gauss_pyr{octave,interval-1}, 'same' );
      
      % Get the DoG Pyramid
      DOG_pyr{octave}(:,:,interval-1) = gauss_pyr{octave,interval} - gauss_pyr{octave,interval-1};
end

% Display the Gaussian and Difference of Gaussian Pyramids
interactive = 1;
if interactive >= 1
   % Display the gaussian pyramid when in interactive mode
   octaves = o;
   intervals = s;
   sz = zeros(1,2);
   sz(2) = (intervals+3)*size(gauss_pyr{1,1},2);
   for octave = 1:octaves
      sz(1) = sz(1) + size(gauss_pyr{octave,1},1);
   end
   pic = zeros(sz);
   y = 1;
   for octave = 1:octaves
      x = 1;
      sz = size(gauss_pyr{octave,1});
      for interval = 1:(intervals + 3)
			pic(y:(y+sz(1)-1),x:(x+sz(2)-1)) = gauss_pyr{octave,interval};		         
         x = x + sz(2);
      end
      y = y + sz(1);
   end
%    fig = figure;
%    clf;
%    showIm(pic);
%    resizeImageFig( fig, size(pic), 0.25 );
%    fprintf( 2, 'The gaussian pyramid (0.25 scale).\nPress any key to continue.\n' );
%    pause;
%    close(fig)
   figure(1);clf; imagesc(pic); colormap gray; axis equal image off; title('高斯滤波图像');
   cdata = print('-RGBImage');
   imwrite(cdata, fullfile([name, '-gauss_pyr.png']));
   
   % Display the Difference of Gaussian Pyramid when in active model
   sz = zeros(1,2);
   sz(2) = (intervals+2)*size(DOG_pyr{1}(:,:,1),2);
   for octave = 1:octaves
      sz(1) = sz(1) + size(DOG_pyr{octave}(:,:,1),1);
   end
   pic = zeros(sz);
   y = 1;
   for octave = 1:octaves
      x = 1;
      sz = size(DOG_pyr{octave}(:,:,1));
      for interval = 1:(intervals + 2)
			pic(y:(y+sz(1)-1),x:(x+sz(2)-1)) = DOG_pyr{octave}(:,:,interval);		         
         x = x + sz(2);
      end
      y = y + sz(1);
   end
%    fig = figure;
%    clf;
%    showIm(pic);
%    resizeImageFig( fig, size(pic), 0.25 );
%    fprintf( 2, 'The DOG pyramid (0.25 scale).\nPress any key to continue.\n' );
%    pause;
%    close(fig)
   figure(2);clf; imagesc(pic); colormap gray; axis equal image off; title('拉普拉斯图像');
   cdata = print('-RGBImage');
   imwrite(cdata, fullfile([name, '-DoGpyramid.png']));   
end   

%%
% 对比阈值滤波
% constrast_threshold for eliminate the points with small value in DoG
if ~exist('contrast_threshold')
    contrast_threshold = 0.02;
end
% 曲率阈值滤波
% curvature_threshold is used for eliminating the points with one big
% eigenvalue and a smaller one.Like Harris edge detection, we need both
% eigenvalues be large enough.
if ~exist('curvature_threshold')
    curvature_threshold = 10.0;
end

dxx = [1 -2 1];
dyy = dxx';
dxy = [ 1 0 -1; 0 0 0; -1 0 1 ]/4;

keypoints = [];
for interval = 2 : s + 1
    % the eliminated margin
    edge =  ceil((filter_size(octave, interval)-1)/2.0);
    edge(edge<1) = 1;
    
    % Get the minima and maxima indicator
    [minima, maxima] = findLocalExtrems(DOG_pyr{octave}, interval, edge);
    
    % Threshold with the contrast_threshold
    beContrast = abs(DOG_pyr{octave}(:,:,interval)) >= contrast_threshold;
    
    % Eliminate the edge points
    Dxx = imfilter(DOG_pyr{octave}(:,:,interval), dxx, 'same');
    Dyy = imfilter(DOG_pyr{octave}(:,:,interval), dyy, 'same'); 
    Dxy = imfilter(DOG_pyr{octave}(:,:,interval), dxy, 'same');
    
    % Compute the trace and the determinant of the Hessian.
    Tr_H = Dxx + Dyy;
    Det_H = Dxx .* Dyy - Dxy.^2;    
    curvature_ratio = (Tr_H).^2 ./ (Det_H + 1e-20);
    
    notEdge = ((Det_H > 0) & ...
    (curvature_ratio < ((curvature_threshold + 1)^2/curvature_threshold)));
    
    % Get the edge points
    [iy,ix] = find( (minima | maxima) & beContrast & notEdge);
    
    % Store the key points
    keypoints = vertcat(keypoints, [ix(:) iy(:) octave*ones(length(ix),1) interval*ones(length(ix),1)]);
    
%     figure(3); imshow(im); hold on;
%         plot(keypoints(:,1), keypoints(:,2), 'rx');
%     hold off;
%     pause();
end

if(interactive)
    figure(3); imshow(im); hold on;
        plot(keypoints(:,1), keypoints(:,2), 'rx','markersize',12);
    hold off;
   cdata = print('-RGBImage');
   imwrite(cdata, fullfile([name, '-keypoint.png']));
   ss = unique(keypoints(:,4));
   for i = 1 : length(ss)
       figure(33); clf; imshow(im); hold on; 
        plot(keypoints(keypoints(:,4) == ss(i),1), keypoints(keypoints(:,4) == ss(i),2), 'rx','markersize',12);
       hold off;
   cdata = print('-RGBImage');
   imwrite(cdata, fullfile([name, '-keypoint',num2str(i),'.png']));       
   end
end

%%
% Compute the gradient direction and magnitude of the gaussian pyramid images
mag_pyr = cell(size(gauss_pyr));
grad_pyr = cell(size(gauss_pyr));
dx = [-1 0 1]/2.0;
dy = dx';
octave = o;
for interval = 2:(intervals+1)      
  % Compute x and y derivatives using pixel differences
  diff_x = imfilter(gauss_pyr{octave, interval}, dx, 'same');
  diff_y = imfilter(gauss_pyr{octave, interval}, dy, 'same');

  % Compute the magnitude of the gradient
  mag = sqrt( diff_x .^ 2 + diff_y .^ 2 );

  % Compute the orientation of the gradient
  grad = atan2( diff_y, diff_x );
  grad((grad == pi)) = -pi;

  % Store the orientation and magnitude of the gradient 
  grad_pyr{octave,interval} = grad;
  mag_pyr{octave, interval} = mag;
end

%%
% Estimate the main direction of the key points

% Set up the histogram bin centers for a 36 bin histogram.
num_bins = 36;
hist_step = 2*pi/num_bins;
hist_orient = [-pi:hist_step:(pi-hist_step)];

% Initialize the positions, orientations, and scale information
% of the keypoints to emtpy matrices.
pos = [];
orient = [];
scale = [];

% Set the Gaussian Filters for integration
Ifilters = cell(o, s + 3);
Hfilters = zeros(o, s+3);
octave = o;
for interval = 2 : ( s + 1)
    g = gaussian_filter(hsize, 1.5 * absolute_sigma(octave, interval));
    Ifilters{octave, interval} = g(:) * g(:)';              % 2维滤波器
    Hfilters(octave, interval) = floor(length(g) / 2.0);    % 半宽
end

% Enumerate the found key points
numKey = size(keypoints, 1);        % 92
keypoint_count = 0;
for i = 1 : numKey
    % Get the position, octave and scale of the key points
    ix = keypoints(i,1); iy = keypoints(i,2);
    io = keypoints(i,3); is = keypoints(i,4);
   
    % Use octave and scale to find the correponding filter and half filter
    % size
    g  = Ifilters{io, is};
    hf = Hfilters(io, is); % get the half size of the octve
    
    % Get the Magnitude and Orientation
    mag = zeros(2 * hf + 1, 2 * hf + 1);
    ori = zeros(2 * hf + 1, 2 * hf + 1);
    
    % get the size of grad and mag
    sz = size(mag_pyr{octave, interval});
    
    % Get the bound around the key point
    xlo = max([ix - hf, 1]) - ix + hf + 1; 
    ylo = max([iy - hf, 1]) - iy + hf + 1;
    xhi = min([ix + hf, sz(2)]) - ix + hf + 1;
    yhi = min([iy + hf, sz(1)]) - iy + hf + 1;
    
    % Crop the region
    mag(ylo : yhi, xlo : xhi) = mag_pyr{octave, interval}((ylo:yhi)-hf -1 + iy, (xlo:xhi)-hf -1 + ix);
    ori(ylo : yhi, xlo : xhi) = grad_pyr{octave, interval}((ylo:yhi)-hf -1 + iy, (xlo:xhi)-hf -1 + ix);
    
    % Use the Gaussian Integration filter to reweight the magnitute
    mag = mag .* g;
    
    % Computer the orientation histogram for the key point
    %{
    owght = 1 - abs(odiff) / hist_step;
    owght(owght < 0) = 0;
    
    % Combine the magnitute and weight;
    wght = repmat(mag(:), [1 num_bins]) .* owght;
    
    % Get the histogram of the orientation
    hist = sum(wght, 1);
    %}
    
    hist = zeros(num_bins);
    for m = ylo: yhi
        for n = xlo: xhi
            angle = ori(m, n);
            locs = find(hist_orient>angle, 1);
            hist(locs) = hist(locs) +  (1 - (hist_orient(locs) - angle)/hist_step) * mag(m, n);
            if locs ==1 
                locs = 36;
            end
            hist(locs-1) = hist(locs-1) + (hist_orient(locs) - angle)/hist_step * mag(m, n);
        end
    end
    
    % Find peaks in the orientation histogram using nonmax suppression.
    peaks = hist(:);        
    rot_right = [ peaks(end); peaks(1:end-1) ];
    rot_left = [ peaks(2:end); peaks(1) ];         
    peaks( (peaks < rot_right) ) = 0;
    peaks( (peaks < rot_left) ) = 0;

    % Extract the value and index of the largest peak. 
    [max_peak_val, ipeak] = max(peaks);

     % Iterate over all peaks within 80% of the largest peak and add keypoints with
     % the orientation corresponding to those peaks to the keypoint list.
     peak_val = max_peak_val;
     while( peak_val > 0.8*max_peak_val )
        % Interpolate the peak by fitting a parabola to the three histogram values
        % closest to each peak.				            
        A = [];
        b = [];
        for j = -1:1
           A = [A; (hist_orient(ipeak)+hist_step*j).^2 (hist_orient(ipeak)+hist_step*j) 1];
           bin = mod( ipeak + j + num_bins - 1, num_bins ) + 1;
           b = [b; hist(bin)];
        end
        c = pinv(A)*b;
        max_orient = -c(2)/(2*c(1));
        while( max_orient < -pi )
           max_orient = max_orient + 2*pi;
        end
        while( max_orient >= pi )
           max_orient = max_orient - 2*pi;
        end            

        % Store the keypoint position, orientation, and scale information
        pos = [pos; [ix iy]];
        orient = [orient; max_orient];
        scale = [scale; io is absolute_sigma(io,is)];
        keypoint_count = keypoint_count + 1;

        % Get the next peak
        peaks(ipeak) = 0;
        [peak_val, ipeak] = max(peaks);
     end      
end

%{
if(interactive >= 1)
    fig = figure(4); clf; imshow(im); 
    display_keypoints( pos, scale(:,3), orient, 'y' );
    
   cdata = print('-RGBImage');
   imwrite(cdata, fullfile([name, '-orient.png']));       
end
%}

%%
% The final of the SIFT algorithm is to extract feature descriptors for the keypoints.
% The descriptors are a grid of gradient orientation histograms, where the sampling
% grid for the histograms is rotated to the main orientation of each keypoint.  The
% grid is a 4x4 array of 4x4 sample cells of 8 bin orientation histograms.  This 
% procduces 128 dimensional feature vectors.

% The orientation histograms have 8 bins
orient_bin_spacing = pi/4;
orient_angles = [-pi:orient_bin_spacing:(pi-orient_bin_spacing)];

% The feature grid is has 4x4 cells - feat_grid describes the cell center positions
grid_spacing = 4;
[x_coords,y_coords] = meshgrid( [-6:grid_spacing:6] );
feat_grid = [x_coords(:) y_coords(:)]'; % the center for the spatial grid
[x_coords,y_coords] = meshgrid( [-(2*grid_spacing-0.5):(2*grid_spacing-0.5)] );
feat_samples = [x_coords(:) y_coords(:)]'; % the points
feat_window = 2*grid_spacing;

% Initialize the descriptor list to the empty matrix.
desc = [];

for k = 1:size(pos,1)
   x = pos(k,1);
   y = pos(k,2);   
   
   % Rotate the grid coordinates.
   M = [cos(orient(k)) -sin(orient(k)); sin(orient(k)) cos(orient(k))];
   feat_rot_grid = M*feat_grid + repmat([x; y],1,size(feat_grid,2));
   feat_rot_samples = M*feat_samples + repmat([x; y],1,size(feat_samples,2));
   
   % Initialize the feature descriptor.
   feat_desc = zeros(1,128);
   
   % Histogram the gradient orientation samples weighted by the gradient magnitude and
   % a gaussian with a standard deviation of 1/2 the feature window.  To avoid boundary
   % effects, each sample is accumulated into neighbouring bins weighted by 1-d in
   % all dimensions, where d is the distance from the center of the bin measured in
   % units of bin spacing.
   for s = 1:size(feat_rot_samples,2)
      x_sample = feat_rot_samples(1,s);
      y_sample = feat_rot_samples(2,s);
            
      % Interpolate the gradient at the sample position
      [X,Y] = meshgrid( (x_sample-1):(x_sample+1), (y_sample-1):(y_sample+1) );
      G = interp2( gauss_pyr{scale(k,1),scale(k,2)}, X, Y, '*linear' );
      G((isnan(G))) = 0;
      diff_x = 0.5*(G(2,3) - G(2,1));
      diff_y = 0.5*(G(3,2) - G(1,2));
      mag_sample = sqrt( diff_x^2 + diff_y^2 );
      grad_sample = atan2( diff_y, diff_x );
      if grad_sample == pi
         grad_sample = -pi;
      end  
      
      % Compute the weighting for the x and y dimensions.
      x_wght = max(1 - (abs(feat_rot_grid(1,:) - x_sample)/grid_spacing), 0);
      y_wght = max(1 - (abs(feat_rot_grid(2,:) - y_sample)/grid_spacing), 0); 
      pos_wght = reshape(repmat(x_wght.*y_wght,8,1),1,128);
      
      % Compute the weighting for the orientation, rotating the gradient to the
      % main orientation to of the keypoint first, and then computing the difference
      % in angle to the histogram bin mod pi.
      diff = mod( grad_sample - orient(k) - orient_angles + pi, 2*pi ) - pi;
      orient_wght = max(1 - abs(diff)/orient_bin_spacing,0);
      orient_wght = repmat(orient_wght,1,16);         
      
      % Compute the gaussian weighting.
      g = exp(-((x_sample-x)^2+(y_sample-y)^2)/(2*feat_window^2))/(2*pi*feat_window^2);
      
      % Accumulate the histogram bins.
      feat_desc = feat_desc + pos_wght.*orient_wght*g*mag_sample;
   end
   
   % Normalize the feature descriptor to a unit vector to make the descriptor invariant
   % to affine changes in illumination.
   feat_desc = feat_desc / norm(feat_desc);
   
   % Threshold the large components in the descriptor to 0.2 and then renormalize
   % to reduce the influence of large gradient magnitudes on the descriptor.
   feat_desc( (feat_desc > 0.2) ) = 0.2;
   feat_desc = feat_desc / norm(feat_desc);
   
   % Store the descriptor.
   desc = [desc; feat_desc];
end