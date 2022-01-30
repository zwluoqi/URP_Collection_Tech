#ifndef _INCLUDE_ZW_CUSTOM_COMMON_HLSL_
#define _INCLUDE_ZW_CUSTOM_COMMON_HLSL_


//利用屏幕空间坐标+深度值转成像素点对应的世界坐标
float4 ConvertDepth2WorldPos(float2 uv,float depth,mat4 viewProjectInverseMatrix){
	float4 H = float4(uv,depth,1);
	float4 D = mul(H,viewProjectInverseMatrix);
	float4 worldPos =D/D.w;
	return worldPos;
}

//计算当前屏幕空间像素的水平运动速度
float2 GetPixelHorSpeed(float2 uv,float depth,mat4 viewProjectInverseMatrix,mat4 preViewProjectMatrix){
	float4 H = float4(uv,depth,1);
	float4 worldPos = ConvertDepth2WorldPos(uv,depth,viewProjectInverseMatrix);
	float4 preH = mul(worldPos,preViewProjectMatrix);
	preH = preH/preH.w;
	float2 velocity = (H-preH)/2.0f;
	return velocity;
}

//计算当前屏幕空间像素的经向运动速度
float2 GetPixelVerSpeed(float2 uv,float depth,mat4 viewProjectInverseMatrix,mat4 preViewProjectMatrix){
	float4 H = float4(uv,depth,1);
	float4 worldPos = ConvertDepth2WorldPos(uv,depth,viewProjectInverseMatrix);
	float4 preH = mul(worldPos,preViewProjectMatrix);
	preH = preH/preH.w;
	float4 velocity = (H-preH)/2.0f;
	return velocity.z;
}

#endif
