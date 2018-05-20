## 仿射变换估计

### Demo

<div align="center">
   <img src="https://github.com/liziniu/cvpr_2018_spring/blob/master/Harris%20Corner%20Detection/affine_registration/concatenate.png">
   <img src="https://github.com/liziniu/cvpr_2018_spring/blob/master/Harris%20Corner%20Detection/affine_registration/merged_img.png">
</div>

### Principle

	# affine transformation is as follows
	
	|x'| = |a11 a12| * |x| + |b1|
	|y'|   |a21 a22|   |y|   |b2|
    
    # so three points are needed to estimate affine matrix 
    
	|x(1) y(1) 1   0    0   0|  |a11|     |x'(1)|
	|0     0   0  x(1) y(1) 1|  |a12|     |y'(1)|
	|x(2) y(2) 1   0    0   0| * |b1| =   |x'(2)|
	|0     0   0  x(2) y(2) 1|  |a21|     |y'(2)|
	|x(3) y(3) 1   0    0   0|  |a22|     |x'(3)|
	|0     0   0  x(3) y(3) 1|   |b2|     |y'(3)|
