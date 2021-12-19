using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;
using Unity.Mathematics;
using UnityEngine;


[BurstCompile]
public struct MergeMeshJob:IJobParallelFor
{

    
    public NativeArray<Vector3> meshVertices;
    public int mesh1Length;
    public Matrix4x4 translate1;
    public Matrix4x4 translate2;

    public void Execute(int index)
    {
        if (index >= mesh1Length)
        {
            meshVertices[index] = translate2 .MultiplyPoint3x4( meshVertices[index]);

        }
        else
        {
            meshVertices[index] = translate1 .MultiplyPoint3x4( meshVertices[index]);
        }
    }


    private float Noise(float x, float y)
    {
        float2 pos = math.float2(x, y);
        return noise.snoise(pos);
    }
}