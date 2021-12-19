Shader "Decal2"
{
    Properties
    {
        Color_5144ed96f4034c62a5a6360cd1536735("MainColor", Color) = (1, 1, 1, 0)
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Pass"
            Tags
            {
                // LightMode: <None>
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM
#pragma enable_d3d11_debug_symbols
            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Color_5144ed96f4034c62a5a6360cd1536735;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_DDXY_float(float In, out float Out)
        {
            Out = abs(ddx(In)) + abs(ddy(In));
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1);
            float4 _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0 = IN.ScreenPosition;
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_R_1 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[0];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_G_2 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[1];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_B_3 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[2];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_A_4 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[3];
            float3 _Divide_3c2d6173b9164feb862cdd907469b630_Out_2;
            Unity_Divide_float3(IN.WorldSpaceViewDirection, (_Split_23b1c3fbbb5847cba5bf9be81d0aff08_A_4.xxx), _Divide_3c2d6173b9164feb862cdd907469b630_Out_2);
            float3 _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2;
            Unity_Multiply_float((_SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1.xxx), _Divide_3c2d6173b9164feb862cdd907469b630_Out_2, _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2);
            float3 _Subtract_511724067fce410eb6f0771cee86759f_Out_2;
            Unity_Subtract_float3(_WorldSpaceCameraPos, _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2, _Subtract_511724067fce410eb6f0771cee86759f_Out_2);
            float3 _Transform_38c538ab1c1144d4be8944ab434355fb_Out_1 = TransformWorldToObject(_Subtract_511724067fce410eb6f0771cee86759f_Out_2.xyz);
            float3 _Absolute_ca6b8870d04e49788020e07f5bb52c88_Out_1;
            Unity_Absolute_float3(_Transform_38c538ab1c1144d4be8944ab434355fb_Out_1, _Absolute_ca6b8870d04e49788020e07f5bb52c88_Out_1);
            float _Length_08a1c6e0803247769241eb509b63e96c_Out_1;
            Unity_Length_float3(_Transform_38c538ab1c1144d4be8944ab434355fb_Out_1, _Length_08a1c6e0803247769241eb509b63e96c_Out_1);
            float3 _Divide_a56e0a505b7d49049e3b78a44ebb314d_Out_2;
            Unity_Divide_float3(_Absolute_ca6b8870d04e49788020e07f5bb52c88_Out_1, (_Length_08a1c6e0803247769241eb509b63e96c_Out_1.xxx), _Divide_a56e0a505b7d49049e3b78a44ebb314d_Out_2);
            float4 _Property_8805cc6f6092445499a99ae3b904f646_Out_0 = Color_5144ed96f4034c62a5a6360cd1536735;
            float3 _Multiply_39ee4813512c400aaa6179dd141e224e_Out_2;
            Unity_Multiply_float(_Divide_a56e0a505b7d49049e3b78a44ebb314d_Out_2, (_Property_8805cc6f6092445499a99ae3b904f646_Out_0.xyz), _Multiply_39ee4813512c400aaa6179dd141e224e_Out_2);
            float _Subtract_dd9a40eff85f47ada826817b274572f9_Out_2;
            Unity_Subtract_float(0.3, _Length_08a1c6e0803247769241eb509b63e96c_Out_1, _Subtract_dd9a40eff85f47ada826817b274572f9_Out_2);
            float _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1;
            Unity_DDXY_float(_Subtract_dd9a40eff85f47ada826817b274572f9_Out_2, _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1);
            float _Divide_edf244e83743450a95e7bc06e6197486_Out_2;
            Unity_Divide_float(_Subtract_dd9a40eff85f47ada826817b274572f9_Out_2, _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1, _Divide_edf244e83743450a95e7bc06e6197486_Out_2);
            float _Saturate_b4c82bac13c84848af133d89930e6af5_Out_1;
            Unity_Saturate_float(_Divide_edf244e83743450a95e7bc06e6197486_Out_2, _Saturate_b4c82bac13c84848af133d89930e6af5_Out_1);
            float _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1;
            Unity_Saturate_float(_Saturate_b4c82bac13c84848af133d89930e6af5_Out_1, _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1);
            surface.BaseColor = _Multiply_39ee4813512c400aaa6179dd141e224e_Out_2;
            surface.Alpha = _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

        	// use bitangent on the fly like in hdrp
        	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph

        	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        	output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM
#pragma enable_d3d11_debug_symbols
            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Color_5144ed96f4034c62a5a6360cd1536735;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_DDXY_float(float In, out float Out)
        {
            Out = abs(ddx(In)) + abs(ddy(In));
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1);
            float4 _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0 = IN.ScreenPosition;
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_R_1 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[0];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_G_2 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[1];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_B_3 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[2];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_A_4 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[3];
            float3 _Divide_3c2d6173b9164feb862cdd907469b630_Out_2;
            Unity_Divide_float3(IN.WorldSpaceViewDirection, (_Split_23b1c3fbbb5847cba5bf9be81d0aff08_A_4.xxx), _Divide_3c2d6173b9164feb862cdd907469b630_Out_2);
            float3 _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2;
            Unity_Multiply_float((_SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1.xxx), _Divide_3c2d6173b9164feb862cdd907469b630_Out_2, _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2);
            float3 _Subtract_511724067fce410eb6f0771cee86759f_Out_2;
            Unity_Subtract_float3(_WorldSpaceCameraPos, _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2, _Subtract_511724067fce410eb6f0771cee86759f_Out_2);
            float3 _Transform_38c538ab1c1144d4be8944ab434355fb_Out_1 = TransformWorldToObject(_Subtract_511724067fce410eb6f0771cee86759f_Out_2.xyz);
            float _Length_08a1c6e0803247769241eb509b63e96c_Out_1;
            Unity_Length_float3(_Transform_38c538ab1c1144d4be8944ab434355fb_Out_1, _Length_08a1c6e0803247769241eb509b63e96c_Out_1);
            float _Subtract_dd9a40eff85f47ada826817b274572f9_Out_2;
            Unity_Subtract_float(0.3, _Length_08a1c6e0803247769241eb509b63e96c_Out_1, _Subtract_dd9a40eff85f47ada826817b274572f9_Out_2);
            float _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1;
            Unity_DDXY_float(_Subtract_dd9a40eff85f47ada826817b274572f9_Out_2, _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1);
            float _Divide_edf244e83743450a95e7bc06e6197486_Out_2;
            Unity_Divide_float(_Subtract_dd9a40eff85f47ada826817b274572f9_Out_2, _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1, _Divide_edf244e83743450a95e7bc06e6197486_Out_2);
            float _Saturate_b4c82bac13c84848af133d89930e6af5_Out_1;
            Unity_Saturate_float(_Divide_edf244e83743450a95e7bc06e6197486_Out_2, _Saturate_b4c82bac13c84848af133d89930e6af5_Out_1);
            float _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1;
            Unity_Saturate_float(_Saturate_b4c82bac13c84848af133d89930e6af5_Out_1, _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1);
            surface.Alpha = _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

        	// use bitangent on the fly like in hdrp
        	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph

        	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        	output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Color_5144ed96f4034c62a5a6360cd1536735;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_DDXY_float(float In, out float Out)
        {
            Out = abs(ddx(In)) + abs(ddy(In));
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1);
            float4 _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0 = IN.ScreenPosition;
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_R_1 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[0];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_G_2 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[1];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_B_3 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[2];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_A_4 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[3];
            float3 _Divide_3c2d6173b9164feb862cdd907469b630_Out_2;
            Unity_Divide_float3(IN.WorldSpaceViewDirection, (_Split_23b1c3fbbb5847cba5bf9be81d0aff08_A_4.xxx), _Divide_3c2d6173b9164feb862cdd907469b630_Out_2);
            float3 _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2;
            Unity_Multiply_float((_SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1.xxx), _Divide_3c2d6173b9164feb862cdd907469b630_Out_2, _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2);
            float3 _Subtract_511724067fce410eb6f0771cee86759f_Out_2;
            Unity_Subtract_float3(_WorldSpaceCameraPos, _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2, _Subtract_511724067fce410eb6f0771cee86759f_Out_2);
            float3 _Transform_38c538ab1c1144d4be8944ab434355fb_Out_1 = TransformWorldToObject(_Subtract_511724067fce410eb6f0771cee86759f_Out_2.xyz);
            float _Length_08a1c6e0803247769241eb509b63e96c_Out_1;
            Unity_Length_float3(_Transform_38c538ab1c1144d4be8944ab434355fb_Out_1, _Length_08a1c6e0803247769241eb509b63e96c_Out_1);
            float _Subtract_dd9a40eff85f47ada826817b274572f9_Out_2;
            Unity_Subtract_float(0.3, _Length_08a1c6e0803247769241eb509b63e96c_Out_1, _Subtract_dd9a40eff85f47ada826817b274572f9_Out_2);
            float _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1;
            Unity_DDXY_float(_Subtract_dd9a40eff85f47ada826817b274572f9_Out_2, _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1);
            float _Divide_edf244e83743450a95e7bc06e6197486_Out_2;
            Unity_Divide_float(_Subtract_dd9a40eff85f47ada826817b274572f9_Out_2, _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1, _Divide_edf244e83743450a95e7bc06e6197486_Out_2);
            float _Saturate_b4c82bac13c84848af133d89930e6af5_Out_1;
            Unity_Saturate_float(_Divide_edf244e83743450a95e7bc06e6197486_Out_2, _Saturate_b4c82bac13c84848af133d89930e6af5_Out_1);
            float _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1;
            Unity_Saturate_float(_Saturate_b4c82bac13c84848af133d89930e6af5_Out_1, _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1);
            surface.Alpha = _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

        	// use bitangent on the fly like in hdrp
        	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph

        	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        	output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Pass"
            Tags
            {
                // LightMode: <None>
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Color_5144ed96f4034c62a5a6360cd1536735;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_Absolute_float3(float3 In, out float3 Out)
        {
            Out = abs(In);
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_DDXY_float(float In, out float Out)
        {
            Out = abs(ddx(In)) + abs(ddy(In));
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1);
            float4 _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0 = IN.ScreenPosition;
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_R_1 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[0];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_G_2 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[1];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_B_3 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[2];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_A_4 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[3];
            float3 _Divide_3c2d6173b9164feb862cdd907469b630_Out_2;
            Unity_Divide_float3(IN.WorldSpaceViewDirection, (_Split_23b1c3fbbb5847cba5bf9be81d0aff08_A_4.xxx), _Divide_3c2d6173b9164feb862cdd907469b630_Out_2);
            float3 _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2;
            Unity_Multiply_float((_SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1.xxx), _Divide_3c2d6173b9164feb862cdd907469b630_Out_2, _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2);
            float3 _Subtract_511724067fce410eb6f0771cee86759f_Out_2;
            Unity_Subtract_float3(_WorldSpaceCameraPos, _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2, _Subtract_511724067fce410eb6f0771cee86759f_Out_2);
            float3 _Transform_38c538ab1c1144d4be8944ab434355fb_Out_1 = TransformWorldToObject(_Subtract_511724067fce410eb6f0771cee86759f_Out_2.xyz);
            float3 _Absolute_ca6b8870d04e49788020e07f5bb52c88_Out_1;
            Unity_Absolute_float3(_Transform_38c538ab1c1144d4be8944ab434355fb_Out_1, _Absolute_ca6b8870d04e49788020e07f5bb52c88_Out_1);
            float _Length_08a1c6e0803247769241eb509b63e96c_Out_1;
            Unity_Length_float3(_Transform_38c538ab1c1144d4be8944ab434355fb_Out_1, _Length_08a1c6e0803247769241eb509b63e96c_Out_1);
            float3 _Divide_a56e0a505b7d49049e3b78a44ebb314d_Out_2;
            Unity_Divide_float3(_Absolute_ca6b8870d04e49788020e07f5bb52c88_Out_1, (_Length_08a1c6e0803247769241eb509b63e96c_Out_1.xxx), _Divide_a56e0a505b7d49049e3b78a44ebb314d_Out_2);
            float4 _Property_8805cc6f6092445499a99ae3b904f646_Out_0 = Color_5144ed96f4034c62a5a6360cd1536735;
            float3 _Multiply_39ee4813512c400aaa6179dd141e224e_Out_2;
            Unity_Multiply_float(_Divide_a56e0a505b7d49049e3b78a44ebb314d_Out_2, (_Property_8805cc6f6092445499a99ae3b904f646_Out_0.xyz), _Multiply_39ee4813512c400aaa6179dd141e224e_Out_2);
            float _Subtract_dd9a40eff85f47ada826817b274572f9_Out_2;
            Unity_Subtract_float(0.3, _Length_08a1c6e0803247769241eb509b63e96c_Out_1, _Subtract_dd9a40eff85f47ada826817b274572f9_Out_2);
            float _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1;
            Unity_DDXY_float(_Subtract_dd9a40eff85f47ada826817b274572f9_Out_2, _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1);
            float _Divide_edf244e83743450a95e7bc06e6197486_Out_2;
            Unity_Divide_float(_Subtract_dd9a40eff85f47ada826817b274572f9_Out_2, _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1, _Divide_edf244e83743450a95e7bc06e6197486_Out_2);
            float _Saturate_b4c82bac13c84848af133d89930e6af5_Out_1;
            Unity_Saturate_float(_Divide_edf244e83743450a95e7bc06e6197486_Out_2, _Saturate_b4c82bac13c84848af133d89930e6af5_Out_1);
            float _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1;
            Unity_Saturate_float(_Saturate_b4c82bac13c84848af133d89930e6af5_Out_1, _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1);
            surface.BaseColor = _Multiply_39ee4813512c400aaa6179dd141e224e_Out_2;
            surface.Alpha = _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

        	// use bitangent on the fly like in hdrp
        	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph

        	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        	output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Color_5144ed96f4034c62a5a6360cd1536735;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_DDXY_float(float In, out float Out)
        {
            Out = abs(ddx(In)) + abs(ddy(In));
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1);
            float4 _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0 = IN.ScreenPosition;
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_R_1 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[0];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_G_2 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[1];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_B_3 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[2];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_A_4 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[3];
            float3 _Divide_3c2d6173b9164feb862cdd907469b630_Out_2;
            Unity_Divide_float3(IN.WorldSpaceViewDirection, (_Split_23b1c3fbbb5847cba5bf9be81d0aff08_A_4.xxx), _Divide_3c2d6173b9164feb862cdd907469b630_Out_2);
            float3 _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2;
            Unity_Multiply_float((_SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1.xxx), _Divide_3c2d6173b9164feb862cdd907469b630_Out_2, _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2);
            float3 _Subtract_511724067fce410eb6f0771cee86759f_Out_2;
            Unity_Subtract_float3(_WorldSpaceCameraPos, _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2, _Subtract_511724067fce410eb6f0771cee86759f_Out_2);
            float3 _Transform_38c538ab1c1144d4be8944ab434355fb_Out_1 = TransformWorldToObject(_Subtract_511724067fce410eb6f0771cee86759f_Out_2.xyz);
            float _Length_08a1c6e0803247769241eb509b63e96c_Out_1;
            Unity_Length_float3(_Transform_38c538ab1c1144d4be8944ab434355fb_Out_1, _Length_08a1c6e0803247769241eb509b63e96c_Out_1);
            float _Subtract_dd9a40eff85f47ada826817b274572f9_Out_2;
            Unity_Subtract_float(0.3, _Length_08a1c6e0803247769241eb509b63e96c_Out_1, _Subtract_dd9a40eff85f47ada826817b274572f9_Out_2);
            float _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1;
            Unity_DDXY_float(_Subtract_dd9a40eff85f47ada826817b274572f9_Out_2, _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1);
            float _Divide_edf244e83743450a95e7bc06e6197486_Out_2;
            Unity_Divide_float(_Subtract_dd9a40eff85f47ada826817b274572f9_Out_2, _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1, _Divide_edf244e83743450a95e7bc06e6197486_Out_2);
            float _Saturate_b4c82bac13c84848af133d89930e6af5_Out_1;
            Unity_Saturate_float(_Divide_edf244e83743450a95e7bc06e6197486_Out_2, _Saturate_b4c82bac13c84848af133d89930e6af5_Out_1);
            float _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1;
            Unity_Saturate_float(_Saturate_b4c82bac13c84848af133d89930e6af5_Out_1, _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1);
            surface.Alpha = _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

        	// use bitangent on the fly like in hdrp
        	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph

        	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        	output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite On
        ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
        #define REQUIRE_DEPTH_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
            float3 WorldSpaceNormal;
            float3 WorldSpaceTangent;
            float3 WorldSpaceBiTangent;
            float3 WorldSpaceViewDirection;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float3 interp3 : TEXCOORD3;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };

            PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.tangentWS = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
        float4 Color_5144ed96f4034c62a5a6360cd1536735;
        CBUFFER_END

        // Object and Global properties

            // Graph Functions
            
        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Divide_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A - B;
        }

        void Unity_Length_float3(float3 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_DDXY_float(float In, out float Out)
        {
            Out = abs(ddx(In)) + abs(ddy(In));
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

            // Graph Vertex
            struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1);
            float4 _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0 = IN.ScreenPosition;
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_R_1 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[0];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_G_2 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[1];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_B_3 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[2];
            float _Split_23b1c3fbbb5847cba5bf9be81d0aff08_A_4 = _ScreenPosition_6a8731c99e704e84a6270b0b6ae594e2_Out_0[3];
            float3 _Divide_3c2d6173b9164feb862cdd907469b630_Out_2;
            Unity_Divide_float3(IN.WorldSpaceViewDirection, (_Split_23b1c3fbbb5847cba5bf9be81d0aff08_A_4.xxx), _Divide_3c2d6173b9164feb862cdd907469b630_Out_2);
            float3 _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2;
            Unity_Multiply_float((_SceneDepth_df7afec1547a4fb0bef54671a3c2ee57_Out_1.xxx), _Divide_3c2d6173b9164feb862cdd907469b630_Out_2, _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2);
            float3 _Subtract_511724067fce410eb6f0771cee86759f_Out_2;
            Unity_Subtract_float3(_WorldSpaceCameraPos, _Multiply_de04124f6dc644b3a7b2c3d79aea4b7c_Out_2, _Subtract_511724067fce410eb6f0771cee86759f_Out_2);
            float3 _Transform_38c538ab1c1144d4be8944ab434355fb_Out_1 = TransformWorldToObject(_Subtract_511724067fce410eb6f0771cee86759f_Out_2.xyz);
            float _Length_08a1c6e0803247769241eb509b63e96c_Out_1;
            Unity_Length_float3(_Transform_38c538ab1c1144d4be8944ab434355fb_Out_1, _Length_08a1c6e0803247769241eb509b63e96c_Out_1);
            float _Subtract_dd9a40eff85f47ada826817b274572f9_Out_2;
            Unity_Subtract_float(0.3, _Length_08a1c6e0803247769241eb509b63e96c_Out_1, _Subtract_dd9a40eff85f47ada826817b274572f9_Out_2);
            float _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1;
            Unity_DDXY_float(_Subtract_dd9a40eff85f47ada826817b274572f9_Out_2, _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1);
            float _Divide_edf244e83743450a95e7bc06e6197486_Out_2;
            Unity_Divide_float(_Subtract_dd9a40eff85f47ada826817b274572f9_Out_2, _DDXY_addc739cbd2e44dea55fd097415a93e9_Out_1, _Divide_edf244e83743450a95e7bc06e6197486_Out_2);
            float _Saturate_b4c82bac13c84848af133d89930e6af5_Out_1;
            Unity_Saturate_float(_Divide_edf244e83743450a95e7bc06e6197486_Out_2, _Saturate_b4c82bac13c84848af133d89930e6af5_Out_1);
            float _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1;
            Unity_Saturate_float(_Saturate_b4c82bac13c84848af133d89930e6af5_Out_1, _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1);
            surface.Alpha = _Saturate_f570797369074a6aa3caccd0d05b8d08_Out_1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

        	// must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
        	float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

        	// use bitangent on the fly like in hdrp
        	// IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
        	float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;		// we want a unit length Normal Vector node in shader graph

        	// to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
        	// This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
        	output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.WorldSpaceViewDirection =     input.viewDirectionWS; //TODO: by default normalized in HD, but not in universal
            output.WorldSpacePosition =          input.positionWS;
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }

            // --------------------------------------------------
            // Main

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
    }
    FallBack "Hidden/Shader Graph/FallbackError"
}