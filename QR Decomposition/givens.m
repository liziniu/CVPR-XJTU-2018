
%{
% demo the givens decomposition
K = [10 0 10; 0 10 10; 0 0 1];

theta = pi/4;
rz = [-cos(theta); -sin(theta); 0];
ry = [0 0 -1]';
rx = [-sin(theta); cos(theta); 0];
R0 = [rx'; ry'; rz'];

P = K * R0;
%}
img = imread('img.jpg');
%img = padarray(img, [5000, 6000]. 255, 'post');
figure;imshow(img);
[xs, ys] = ginput(3);
P = [xs;ys;ones(3,1)];
%{
P = [13.1   7417.9  811.3;
     927.9, 521.5, 7519.9;
     1        1      1];
%}

%%
% decompose for illustration
sols = cell(4,1); 
sols{1} = P; % intialize the solution
rots{1} = eye(3); % intialize the rotation matrix
for i = 1 : 3
    sz = size(sols{i});
    cM = []; cR = [];
    for j = 1 : size(sols{i},3)
        M = squeeze(sols{i}(:,:,j));
        R = squeeze(rots{i}(:,:,j));
        
        % [c -s 0;
        %  s  c 0;
        %  0  0 1;]
        %  s = p32 / sqrt(p32^2 + p31^2)
        %  c = p31 / sqrt(p32^2 + p31^2)
        if(i==1)
            c = M(3,2)/(sqrt(M(3,1)^2+M(3,2)^2)+1e-20);
            s = M(3,1)/(sqrt(M(3,1)^2+M(3,2)^2)+1e-20);
            % two possibility
            R1 = [c -s 0; s c 0; 0 0 1];
            R2 = [-c s 0; -s -c 0; 0 0 1];
        end
        % [c  0  s;
        %  0  0  1;
        %  -s 0  c;]
        %  s = p33 / sqrt(p33^2 + p31^2)
        %  c = p31 / sqrt(p33^2 + p31^2)
        if(i==2)
            c = M(3,3)/(sqrt(M(3,1)^2+M(3,3)^2)+1e-20);
            s = M(3,1)/(sqrt(M(3,1)^2+M(3,3)^2)+1e-20);
            R1 = [c 0 s; 0 1 0; -s 0 c];
            R2 = [-c 0 -s; 0 1 0; s 0 -c];
        end
        % [c -s 0;
        %  s  c 0;
        %  0  0 1;]
        %  s = -p21 / sqrt(p21^2 + p22^2)
        %  c =  p22 / sqrt(p21^2 + p22^2)
        if(i==3)
            c = M(2,2)/(sqrt(M(2,1)^2+M(2,2)^2)+1e-20);
            s = -M(2,1)/(sqrt(M(2,1)^2+M(2,2)^2)+1e-20);
            R1 = [c -s 0; s c 0; 0 0 1];
            R2 = [-c s 0; -s -c 0; 0 0 1];
        end
        if(isempty(cM))
            cM = cat(3, M * R1, M * R2);
            cR = cat(3, R * R1, R * R2);
        else
            cM = cat(3, cM, M * R1, M * R2);
            cR = cat(3, cR, R * R1, R * R2);
        end
    end
    sols{i+1} = cM;
    rots{i+1} = cR;
end

for i = 1 : size(rots{4},3)
   rots{4}(:,:,i) = (rots{4}(:,:,i))';
end

%%
% write your code here, write some checking code to check the validality of
% your QR decomposition
index = 1;
for i = 1:8
    k = sols{4}(:, :, i);
    if k(1, 1) > 0 && k(2, 2) > 0 && k(3, 3) > 0
        est_k = k
        est_r = rots{4}(:, :, i)
        break;
    end
end

