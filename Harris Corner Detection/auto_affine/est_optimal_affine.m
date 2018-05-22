% 根据3个点估计仿射变换矩阵, points2 -> points1
function F = est_optimal_affine(points1, points2)
    if (any(size(points1)~= [3, 2]))
        error('points1 should have 3 points');
    end
    if (any(size(points2)~= [3, 2]))
        error('points2 should have 3 points');
    end
    
    A = [points1(1, 1), points1(1, 2), 1,      0,              0,       0;
            0,             0,          0, points1(1, 1), points1(1, 2), 1;
         points1(2, 1), points1(2, 2), 1,      0,              0,       0;
            0,             0,          0, points1(2, 1), points1(2, 2), 1;
         points1(3, 1), points1(3, 2), 1,      0,              0,       0;
            0,             0,          0, points1(3, 1), points1(3, 2), 1];
    b = [points2(1, 1); points2(1, 2);
         points2(2, 1); points2(2, 2);
         points2(3, 1); points2(3, 2)];
    
    x = A\b;
    F = [x(1:3)'; x(4:6)'];
end