function [Mx, Tbx] = cumMinEngVer(e)
% e is the energy map.
% Mx is the cumulative minimum energy map along vertical direction.
% Tbx is the backtrack table along vertical direction.

[ny,nx] = size(e);
%% add your code here

Mx_pad = zeros(ny, nx+2);
Mx_pad(1, 2:end-1) = e(1, :);
Mx_pad(:, 1) = inf; Mx_pad(:, end) = inf;
Tbx = zeros(ny, nx);
for j = 2:ny
    for i = 1:nx
        min_value = min(Mx_pad(j-1, i:i+2));
        min_index = find(Mx_pad(j-1, i:i+2) == min_value, 1);
        Mx_pad(j, i+1) = e(j, i) + min_value;
        Tbx(j, i) = i + min_index - 2;
    end
end
Mx = Mx_pad(:, 2:end-1);

end