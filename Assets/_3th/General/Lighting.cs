using Unity.Mathematics;

namespace _3th.General
{
    public class Lighting
    {
        public static float3 SampleSH9(float4[] SHCoefficients, float3 N)
        {
            float4 shAr = SHCoefficients[0];
            float4 shAg = SHCoefficients[1];
            float4 shAb = SHCoefficients[2];
            float4 shBr = SHCoefficients[3];
            float4 shBg = SHCoefficients[4];
            float4 shBb = SHCoefficients[5];
            float4 shCr = SHCoefficients[6];

            // Linear + constant polynomial terms
            float3 res = SHEvalLinearL0L1(N, shAr, shAg, shAb);

            // Quadratic polynomials
            res += SHEvalLinearL2(N, shBr, shBg, shBb, shCr);

    // #ifdef UNITY_COLORSPACE_GAMMA
            res = LinearToSRGB(res);
    // #endif

            return res;
        }
        
        // Ref: "Efficient Evaluation of Irradiance Environment Maps" from ShaderX 2
        public static float3 SHEvalLinearL0L1(float3 N, float4 shAr, float4 shAg, float4 shAb)
        {
            float4 vA = new float4(N, 1.0f);

            float3 x1;
            // Linear (L1) + constant (L0) polynomial terms
            x1.x = Unity.Mathematics.math.dot(shAr, vA);
            x1.y = Unity.Mathematics.math.dot(shAg, vA);
            x1.z = Unity.Mathematics.math.dot(shAb, vA);

            return x1;
        }
        
        
        public static float3 SHEvalLinearL2(float3 N, float4 shBr, float4 shBg, float4 shBb, float4 shC)
        {
            float3 x2;
            // 4 of the quadratic (L2) polynomials
            float4 vB = N.xyzz * N.yzzx;
            x2.x = Unity.Mathematics.math.dot(shBr, vB);
            x2.y = Unity.Mathematics.math.dot(shBg, vB);
            x2.z = Unity.Mathematics.math.dot(shBb, vB);

            // Final (5th) quadratic (L2) polynomial
            float vC = N.x * N.x - N.y * N.y;
            float3 x3 = shC.xyz * vC;

            return x2 + x3;
        }
        
        public static float LinearToSRGB(float c)
        {
            float sRGBLo = c * 12.92f;
            float sRGBHi = (Unity.Mathematics.math.pow(c, 1.0f/2.4f) * 1.055f) - 0.055f;
            float sRGB   = (c <= 0.0031308) ? sRGBLo : sRGBHi;
            return sRGB;
        }
        
        
        public static float2 LinearToSRGB(float2 c)
        {
            float2 sRGBLo = c * 12.92f;
            float2 sRGBHi = (Unity.Mathematics.math.pow(c, new float2(1.0f/2.4f, 1.0f/2.4f)) * 1.055f) - 0.055f;
            float2 sRGB   = (c.x <= 0.0031308&&c.y <= 0.0031308f) ? sRGBLo : sRGBHi;
            return sRGB;
        }

        public static float3 LinearToSRGB(float3 c)
        {
            float3 sRGBLo = c * 12.92f;
            float3 sRGBHi = (Unity.Mathematics.math.pow(c, new float3(1.0f/2.4f, 1.0f/2.4f, 1.0f/2.4f)) * 1.055f) - 0.055f;
            float3 sRGB   = (c.x <= 0.0031308f&&c.y <= 0.0031308f&&c.z <= 0.0031308f) ? sRGBLo : sRGBHi;
            return sRGB;
        }

        public static float4 LinearToSRGB(float4 c)
        {
            return new float4(LinearToSRGB(c.xyz), c.w);
        }
    }
}