Shader "Unlit/SimpleCloud-2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _FlowSpeed("FlowSpeed",float) = 0.1
        _FlowWidth("FlowWidth",float) = 1        
        _WriggleSpeed("WriggleSpeed",float) = 0.1
        _WriggleVertexDivergence("WriggleVertexDivergence",float) = 0.1
        _WriggleMagnitude("WriggleMagnitude",float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="TransParent" "Queue" = "TransParent" }
        LOD 100

        Pass
        {
        
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Cull Off
        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            

            #include "UnityCG.cginc"
            #include "../General/NoiseShader/ClassicNoise2D.hlsl"


            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _FlowSpeed;
            float _WriggleSpeed;
            float _WriggleVertexDivergence;
            float _WriggleMagnitude;
            float _FlowWidth;

            v2f vert (appdata v)
            {
                v2f o;

                float4 vertex = v.vertex;
               
                vertex = mul(UNITY_MATRIX_M, float4(vertex.xyz, 1.0));
                vertex = mul(UNITY_MATRIX_VP, float4(vertex.xyz, 1.0));

                
                // move the cloud around as a whole
                vertex.xy += sin(_Time.y * _FlowSpeed) * _FlowWidth;
                // move every vertex around individually,  and make their movement different from each other, which makes the cloud look like wriggling
                vertex.xyz += (sin(_Time.w * _WriggleSpeed + (v.vertex.x + v.vertex.y + v.vertex.z) * _WriggleVertexDivergence) + 1.0) * _WriggleMagnitude;
                

                o.vertex = vertex;
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // generate perlin noise in real-time, 
                fixed perlinNoise = (ClassicNoise(i.uv * 4.0 + _Time.x * 10.0) + 1) * 0.5;
                fixed alpha = perlinNoise;
                
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);

                return fixed4(1.0, 1.0, 1.0, alpha);
            }
            ENDCG
        }
    }
}
