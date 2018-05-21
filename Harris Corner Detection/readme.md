## Harris 角点检测


### Demo

<div align="center">
  <img src="https://github.com/liziniu/cvpr_2018_spring/blob/master/Harris%20Corner%20Detection/img/pic.png"  height="400" width="500" title="origin image">
  
  <img src="https://github.com/liziniu/cvpr_2018_spring/blob/master/Harris%20Corner%20Detection/img/corners.png" height="400" width="600" title="corner">
</div>
  

### Principle(Chinese)

1. 计算图像的Ix, Iy方向梯度


2. 计算子相关矩阵A， 分别计算Ixx, Ixy, Iyy
    
    	A = [Ix.*Ix,  Ix.*Iy
             Iy.*Ix,  Iy.*Iy]
             
3. 高斯对A进行Ixx, Ixy, Iyy进行滤波


4. 求解响应值R

		R = det(A) - k*(trace(A)**2)
		
5. 对响应值R进行Non-Local Depression

6. 对极大值抑制后的R进行阈值滤波

7. 对最终满足条件的R进行角点标记
