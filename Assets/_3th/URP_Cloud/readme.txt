1.In.通过比较差值边缘深度值进行云的与其他物体交界位置的虚化,
2.shader公式越远离山,云的权重越高,越靠近山，alpha越低，晕的权重越低。
3.alphatest的值随噪声变化
4.urp需要打开depth texture，LinearEyeDepth拿不到深度值，无法进行边缘虚化


注意：
1.ScreenPosition.w,此时的w相当于clip空间下该顶点的z值，选用raw模式是因为此时的w分量没做归一化
2.混合模式 Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha。