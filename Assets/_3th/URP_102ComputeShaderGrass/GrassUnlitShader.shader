Shader "Unlit/GrassUnlitShader"
{
    Properties
    {
        _TopColor("Color", Color) = (1,1,1,1)
        _BottomColor("Color", Color) = (0,0,0,0)
    }
    SubShader
    {
		Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" }

        LOD 300
        Cull Off

        Pass
        {
			Name "ForwardLit"
			Tags {"LightMode" = "UniversalForward"}


            HLSLPROGRAM
            #pragma vertex vert 
            #pragma fragment frag


            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
			#pragma multi_compile _ _SHADOWS_SOFT
   //          

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            struct Attributes
            {
                float3 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
                float3 normalOS   : NORMAL;
                half4 tangentOS     : TANGENT;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                half3 normalWS : TEXCOORD1;
                half3 positionWS : TEXCOORD2;
                float4 positionCS               : SV_POSITION;
            };

			// Variables
			CBUFFER_START(UnityPerMaterial) // Required to be compatible with SRP Batcher
            float4 _TopColor;
            float4 _BottomColor;
            CBUFFER_END
            
            Varyings vert (Attributes v)
            {
                Varyings o = (Varyings)0;
                
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS.xyz);
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(v.normalOS, v.tangentOS);

                o.positionWS = vertexInput.positionWS;
                o.uv = v.uv;
                o.normalWS = vertexNormalInput.normalWS;
                o.positionCS = vertexInput.positionCS;

                return o;
            }
            
            float4 frag (Varyings input) : SV_Target
            {

            	
                #if SHADOWS_SCREEN
					float4 clipPos = TransformWorldToHClip(input.positionWS);
					float4 shadowCoord = ComputeScreenPos(clipPos);
				#else
					float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
				#endif
    
                //环境光
                float3 ambient = SampleSH(input.normalWS);
                
    
                Light mainLight = GetMainLight(shadowCoord);
				float NdotL = saturate(saturate(dot(input.normalWS, mainLight.direction)) + 0.8);
				float up = saturate(dot(float3(0,1,0), mainLight.direction) + 0.5);
    
				float3 shading = NdotL * up * mainLight.shadowAttenuation * mainLight.color + ambient;
    
                return lerp(_BottomColor, _TopColor, input.uv.y) * float4(shading, 1);
    
                
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
			Tags {"LightMode" = "ShadowCaster"}

			            // more explict render state to avoid confusion
            ZWrite On // the only goal of this pass is to write depth!
            ZTest LEqual // early exit at Early-Z stage if possible            
            ColorMask 0 // we don't care about color, we just want to write depth, ColorMask 0 will save some write bandwidth
            Cull Back // support Cull[_Cull] requires "flip vertex normal" using VFACE in fragment shader, which is maybe beyond the scope of a simple tutorial shader

            HLSLPROGRAM

            // the only keywords we need in this pass = _UseAlphaClipping, which is already defined inside the HLSLINCLUDE block
            // (so no need to write any multi_compile or shader_feature in this pass)

            #pragma vertex Vertex
            #pragma fragment BaseColorAlphaClipTest // we only need to do Clip(), no need shading

            // because it is a ShadowCaster pass, define "ToonShaderApplyShadowBiasFix" to inject "remove shadow mapping artifact" code into VertexShaderWork()
            
			// #define SHADERPASS_SHADOWCASTER

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float3 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
                float3 normalOS   : NORMAL;
                half4 tangentOS     : TANGENT;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                half3 normalWS : TEXCOORD1;
                float4 positionWSAndFogFactor:TEXCOORD2;
                float4 positionCS               : SV_POSITION;
            };
			// Variables
			CBUFFER_START(UnityPerMaterial) // Required to be compatible with SRP Batcher
            float4 _TopColor;
            float4 _BottomColor;
            CBUFFER_END
            //a special uniform for applyShadowBiasFixToHClipPos() only, it is not a per material uniform, 
            //so it is fine to write it outside our UnityPerMaterial CBUFFER
            float3 _LightDirection;

            
            // #define ToonShaderApplyShadowBiasFix
            // all shader logic written inside this .hlsl, remember to write all #define BEFORE writing #include
            // #include "SimpleURPToonLitOutlineExample_Shared.hlsl"
            Varyings Vertex(Attributes input)
            {
                Varyings output;

                // VertexPositionInputs contains position in multiple spaces (world, view, homogeneous clip space, ndc)
                // Unity compiler will strip all unused references (say you don't use view space).
                // Therefore there is more flexibility at no additional cost with this struct.
                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS);

                // Similar to VertexPositionInputs, VertexNormalInputs will contain normal, tangent and bitangent
                // in world space. If not used it will be stripped.
                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                float3 positionWS = vertexInput.positionWS;

                // Computes fog factor per-vertex.
                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

                // TRANSFORM_TEX is the same as the old shader library.
                output.uv = input.uv;//TRANSFORM_TEX(input.uv,_BaseMap);

                // packing positionWS(xyz) & fog(w) into a vector4
                output.positionWSAndFogFactor = float4(positionWS, fogFactor);
                output.normalWS = vertexNormalInput.normalWS; //normlaized already by GetVertexNormalInputs(...)

                output.positionCS = TransformWorldToHClip(positionWS);

                //0.shadowcast情况下，根据pcff等原理，这时候的mvp是基于光源形成的矩阵，所以转换的坐标都是在光源体系下。
                //1.根据光线和法线方向偏移position
                //2.限制在CLIP RECT空间内
                // see GetShadowPositionHClip() in URP/Shaders/ShadowCasterPass.hlsl
                // https://github.com/Unity-Technologies/Graphics/blob/master/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl
                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, output.normalWS, _LightDirection));
                #if UNITY_REVERSED_Z
                positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #else
                positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #endif
                output.positionCS = positionCS;

            	
                return output;
            }

            void DoClipTestToTargetAlphaValue(half alpha) 
            {
            #if _UseAlphaClipping
                clip(alpha - _Cutoff);
            #endif
            }
                        
            //////////////////////////////////////////////////////////////////////////////////////////
            // fragment shared functions (for ShadowCaster pass & DepthOnly pass to use only)
            //////////////////////////////////////////////////////////////////////////////////////////
            void BaseColorAlphaClipTest(Varyings input)
            {
                DoClipTestToTargetAlphaValue(_BottomColor.a);
            }
                        
            ENDHLSL
        }

		Pass{
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            // more explict render state to avoid confusion
            ZWrite On // the only goal of this pass is to write depth!
            ZTest LEqual // early exit at Early-Z stage if possible            
            ColorMask 0 // we don't care about color, we just want to write depth, ColorMask 0 will save some write bandwidth
            Cull Back // support Cull[_Cull] requires "flip vertex normal" using VFACE in fragment shader, which is maybe beyond the scope of a simple tutorial shader
            
            HLSLPROGRAM

            #pragma vertex DepthOnlyVertex
            #pragma fragment BaseColorAlphaClipTest
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 position     : POSITION;
                float2 texcoord     : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                float4 positionCS   : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };
			// Variables
			CBUFFER_START(UnityPerMaterial) // Required to be compatible with SRP Batcher
            float4 _TopColor;
            float4 _BottomColor;
            CBUFFER_END
            Varyings DepthOnlyVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                output.uv = input.texcoord;
                output.positionCS = TransformObjectToHClip(input.position.xyz);
                return output;
            }

            void DoClipTestToTargetAlphaValue(half alpha) 
            {
            #if _UseAlphaClipping
                clip(alpha - _Cutoff);
            #endif
            }
                        
            //////////////////////////////////////////////////////////////////////////////////////////
            // fragment shared functions (for ShadowCaster pass & DepthOnly pass to use only)
            //////////////////////////////////////////////////////////////////////////////////////////
            void BaseColorAlphaClipTest(Varyings input)
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                DoClipTestToTargetAlphaValue(_BottomColor.a);
            }
            ENDHLSL
		}
    }
}
