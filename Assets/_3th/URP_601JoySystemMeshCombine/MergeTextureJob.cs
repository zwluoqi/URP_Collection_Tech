using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;
using UnityEngine;

[BurstCompile]
public struct MergeTextureJob:IJobParallelFor
{
    public NativeArray<Color32> color32s;

    public int texture1Length;
    
    public void Execute(int index)
    {
        
    }
}