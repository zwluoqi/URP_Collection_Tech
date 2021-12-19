using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;
using UnityEngine;

[BurstCompile]
public struct MergeUVJob:IJobParallelFor
{
    public NativeArray<Vector2> meshUV01s;

    public  int mesh1UVLength;


    private static readonly Vector2 offset = new Vector2(0.0f, 0.5f);

    public void Execute(int index)
    {
        if (index >= mesh1UVLength)
        {
            meshUV01s[index] = meshUV01s[index] * 0.5f + offset;
        }
        else
        {
            meshUV01s[index] = meshUV01s[index] * 0.5f;
        }
    }
}