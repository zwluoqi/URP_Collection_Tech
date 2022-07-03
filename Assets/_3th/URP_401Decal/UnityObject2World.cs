using System;
using System.Collections;
using System.Collections.Generic;
using _3th.General;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteAlways]
public class UnityObject2World : MonoBehaviour
{

    public Matrix4x4 obj2World;
    public Matrix4x4 world2Obj;
    public Vector4[] unity_SHA_RGB = new Vector4[3];
    public Vector4[] unity_SHB_RGB = new Vector4[3];
    public Vector4 unity_SHC;
    public float3 upSampleSH;
    public int lightMapSetttingBackProbeCount;
    public void Update()
    {
        obj2World = this.transform.localToWorldMatrix;
        world2Obj = this.transform.worldToLocalMatrix;

        // SphericalHarmonicsL3 s;
            
        SphericalHarmonicsL2 sh;
        // var probes = LightmapSettings.lightProbes.bakedProbes;
        // lightMapSetttingBackProbeCount = probes.Length;
        LightProbes.GetInterpolatedProbe(this.transform.position, GetComponent<Renderer>(), out sh);
        
        
        // Constant + Linear
        for (var i = 0; i < 3; i++)
            unity_SHA_RGB[i]= new Vector4(
                sh[i, 3], sh[i, 1], sh[i, 2], sh[i, 0] - sh[i, 6] 
            );

        // Quadratic polynomials
        for (var i = 0; i < 3; i++)
            unity_SHB_RGB[i]= new Vector4(
                sh[i, 4], sh[i, 6], sh[i, 5] * 3, sh[i, 7]
            );

        // Final quadratic polynomial
        unity_SHC = new Vector4(
            sh[0, 8], sh[2, 8], sh[1, 8], 1
        );
        upSampleSH = SampleSH(Vector3.up);
    }
    
    // Samples SH L0, L1 and L2 terms
    float3 SampleSH(float3 normalWS)
    {
        // LPPV is not supported in Ligthweight Pipeline
        float4[] SHCoefficients = new float4[7];
        SHCoefficients[0] = unity_SHA_RGB[0];
        SHCoefficients[1] = unity_SHA_RGB[1];
        SHCoefficients[2] = unity_SHA_RGB[2];
        SHCoefficients[3] = unity_SHB_RGB[0];
        SHCoefficients[4] = unity_SHB_RGB[1];
        SHCoefficients[5] = unity_SHB_RGB[2];
        SHCoefficients[6] = unity_SHC;

        return Unity.Mathematics.math.max(new float3(0.0f, 0.0f, 0.0f), Lighting.SampleSH9(SHCoefficients, normalWS));
    }
}
