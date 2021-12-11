using System;
using System.Collections;
using System.Collections.Generic;
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
    
    public void Update()
    {
        obj2World = this.transform.localToWorldMatrix;
        world2Obj = this.transform.worldToLocalMatrix;
        
        SphericalHarmonicsL2 sh;
        LightProbes.GetInterpolatedProbe(this.transform.position, null, out sh);
        
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
    }
}
