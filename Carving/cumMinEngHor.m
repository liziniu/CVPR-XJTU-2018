function [My, Tby] = cumMinEngHor(e)
% e is the energy map.
% My is the cumulative minimum energy map along horizontal direction.
% Tby is the backtrack table along horizontal direction.

[ny,nx] = size(e);

%% Add your code here
%{
My = zeros(ny, nx);
Tby = zeros(ny, nx);
My(:,1) = e(:,1);
for i = 2:nx
    for j = 1: ny
        if j > 1 && j < ny
            min_value = min(My(j-1:j+1, i));
            min_index = find(My(j-1:j+1, i) == min_value, 1);
            My(j, i) = e(j, i) + min_value;
            Tby(j, i) = j + min_index - 2;
        else if j == 1
                min_value = min(My(j:j+1, i));
                min_index = find(My(j-1:j+1, i) == min_value, 1);
                My(j, i) = e(j, i) + min_value;
                Tby(j, i) = j + min_index - 1;
            else
                min_value = min(My(j-1:j, i);
                min_index = find(My(j-1:j, i) == min_value, 1);
                My(j, i) = e(j, i) + min_value;
                Tby(j, i) = j + min_index - 2;
            end
        end
    end
end
%}

My_pad = zeros(ny+2, nx);
Tby = zeros(ny, nx);
My_pad(2:end-1,1) = e(:,1);
My_pad(1, :) = inf; My_pad(end, :) = inf;
for i = 2:nx
    for j = 1:ny
        min_value = min(My_pad(j:j+2, i-1));
        min_index = find(My_pad(j:j+2, i-1) == min_value, 1);
        My_pad(j+1, i) = e(j, i) + min_value;
        Tby(j, i) = j + min_index - 2;
    end
end

My = My_pad(2:end-1, :); 
end