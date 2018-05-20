## 仿射变换估计



### Principle

	# affine transformation is as follows
	
	|x'| = |a11 a12| * |x| + |b1|
	|y'|   |a21 a22|   |y|   |b2|
    
    # so three points are needed to estimate affine matrix 
    
	|x(1) y(1) 1   0    0   0|  |a11|     |x'(1)|
	|0     0   0  x(1) y(1) 1|  |a12|     |y'(1)|
	|x(2) y(2) 1   0    0   0| * |b1| =   |x'(1)|
	|0     0   0  x(2) y(2) 1|  |a21|     |y'(1)|
	|x(3) y(3) 1   0    0   0|  |a22|     |x'(1)|
	|0     0   0  x(3) y(3) 1|   |b2|     |y'(1)|
