## Gradient Blend

### Demo

 Mask | Result
 ---- | ------
 ![mask1](https://github.com/liziniu/cvpr_2018_spring/blob/master/Gradient%20Blend/img/mask1.png) | ![res1](https://github.com/liziniu/cvpr_2018_spring/blob/master/Gradient%20Blend/img/res1.png) |
 ![mask2](https://github.com/liziniu/cvpr_2018_spring/blob/master/Gradient%20Blend/img/mask2.png) | ![res2](https://github.com/liziniu/cvpr_2018_spring/blob/master/Gradient%20Blend/img/res2.png) | 
 ![mask3](https://github.com/liziniu/cvpr_2018_spring/blob/master/Gradient%20Blend/img/mask3.png) | ![res3](https://github.com/liziniu/cvpr_2018_spring/blob/master/Gradient%20Blend/img/res3.png) | 
 ![mask4](https://github.com/liziniu/cvpr_2018_spring/blob/master/Gradient%20Blend/img/mask4.png) | ![res4](https://github.com/liziniu/cvpr_2018_spring/blob/master/Gradient%20Blend/img/res4.png)


### How to use it

1. Draw a mask free hand.

2. Drag it until you double to decide it.

3. Click to choose the mask center point.

4. Click a point to place mask in the background image. 


### Principle(Chinese)
1. 在源图像中标记出mask
2. 计算mask区域的Laplace
3. 对目标图像的mask区域进行变量标号
4. 保持目标图像的mask边缘像素值不变，列出系数矩阵A和b
5. 求解变量
6. 将变量值copy到目标图像的mask区域
