function [Ic, T] = carv(I, nr, nc)
% I is the image being resized
% [nr, nc] is the numbers of rows and columns to remove.
% Ic is the resized image
% T is the transport map

[ny, nx, nz] = size(I);
T = zeros(nr+1, nc+1);
TI = cell(nr+1, nc+1);
TI{1,1} = I;
% TI is a trace table for images. TI{r+1,c+1} records the image removed r rows and c columns.

%% Add your code here
% first column
for i = 2:nr+1
    I = TI{i-1, 1};
    e =  genEngMap(I);
    [My, Tby] = cumMinEngHor(e);
    [Iy, Ey] = rmHorSeam(I, My, Tby);
    TI{i, 1} = Iy;
    T(i, 1) = T(i-1, 1) + Ey;
end
% first row
for i = 2:nc+1
    I = TI{1, i-1};
    e =  genEngMap(I);
    [Mx, Tbx] = cumMinEngVer(e);
    [Ix, Ex] = rmVerSeam(I, Mx, Tbx);
    TI{1, i} = Ix;
    T(1, i) = T(1, i) + Ex;
end
% dynamic programming
for i = 2:nr+1
    for j = 2:nc+1
        I = TI{i-1, j};
        e = genEngMap(I);
        [My, Tby] = cumMinEngHor(e);
        [Iy, Ey] = rmHorSeam(I, My, Tby);
        
        I = TI{i, j-1};
        e = genEngMap(I);
        [Mx, Tbx] = cumMinEngVer(e);
        [Ix, Ex] = rmVerSeam(I, Mx, Tbx);
        
        if T(i, j-1) + Ex <  T(i-1, j) + Ey
            TI{i, j} = Ix;
            T(i, j) = T(i, j-1) + Ex;
        else
            TI{i, j} = Iy;
            T(i, j) = T(i-1, j) + Ey;
        end
    end
end

Ic = TI{nr+1, nc+1};
        
        
        
        
        
        
