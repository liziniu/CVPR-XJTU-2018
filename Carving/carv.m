function [Ic, T] = carv(I, nr, nc, type)
% I is the image being resized
% [nr, nc] is the numbers of rows and columns to remove.
% Ic is the resized image
% T is the transport map
if ~exist('type', 'var')
    type = 'NC';
end
[ny, nx, nz] = size(I);
T = zeros(nr+1, nc+1);
TI = cell(nr+1, nc+1);
TMask = cell(nr+1, nc+1);
TI{1,1} = I;

% TI is a trace table for images. TI{r+1,c+1} records the image removed r rows and c columns.

%% Add your code here
% create mask
if ~strcmp(type, 'NC')
    mask = create_mask(I);
else
    mask = zeros(ny, nx);
end
TMask{1, 1} = mask;

figure(1);
subplot(1, 3, 1);
imshow(I);
subplot(1, 3, 2);
imshow(mask);
% first column
for i = 2:nr+1
    I = TI{i-1, 1};
    mask = TMask{i-1, 1};
    e =  genEngMap(I,mask, type);
    [My, Tby] = cumMinEngHor(e);
    [Iy, Ey, rmask] = rmHorSeam(I, My, Tby, mask);
    TI{i, 1} = Iy;
    TMask{i, 1} = rmask;
    T(i, 1) = T(i-1, 1) + Ey;
end
% first row
for i = 2:nc+1
    I = TI{1, i-1};
    mask = TMask{1, i-1};
    e =  genEngMap(I,mask,type);
    [Mx, Tbx] = cumMinEngVer(e);
    [Ix, Ex, rmask] = rmVerSeam(I, Mx, Tbx, mask);
    TI{1, i} = Ix;
    TMask{1, i} = rmask;
    T(1, i) = T(1, i) + Ex;
end
% dynamic programming
for i = 2:nr+1
    for j = 2:nc+1
        I = TI{i-1, j};
        mask = TMask{i-1, j};
        e = genEngMap(I, mask);
        [My, Tby] = cumMinEngHor(e);
        [Iy, Ey, Masky] = rmHorSeam(I, My, Tby, mask);
        
        I = TI{i, j-1};
        mask = TMask{i, j-1};
        e = genEngMap(I, mask);
        [Mx, Tbx] = cumMinEngVer(e);
        [Ix, Ex, Maskx] = rmVerSeam(I, Mx, Tbx, mask);
        
        if T(i, j-1) + Ex <  T(i-1, j) + Ey
            TI{i, j} = Ix;
            TMask{i, j} = Maskx;
            T(i, j) = T(i, j-1) + Ex;
        else
            TI{i, j} = Iy;
            TMask{i, j} = Masky;
            T(i, j) = T(i-1, j) + Ey;
        end
    end
end

Ic = TI{nr+1, nc+1};
subplot(1, 3, 3);
imshow(Ic);
