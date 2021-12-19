using System.Collections;
using System.Collections.Generic;
using Unity.Burst;
using Unity.Collections;
using Unity.Collections.LowLevel.Unsafe;
using Unity.Jobs;
using UnityEngine;

[BurstCompile]
public struct ParticleSystemJoy :IJobParallelFor
{
    [ReadOnly]
    public NativeArray<JoySystemParticleSystem.Particle> particles;
    
    public NativeArray<Vector3> m_Positions;
    
    
    public float delta;
    public void Execute(int index)
    {
        var  size = 0.5f;
        var pIndex = index / 4;
        var vIndex = index % 4;
        var p = particles[pIndex];
        p.pos += p.dir * p.speed *delta;

        //[1  3]
        //[0  2]
        if (vIndex == 0)
        {
            m_Positions[index ] = p.pos + new Vector3(-size, -size, 0);
        }else if (vIndex == 1)
        {
            m_Positions[index] = p.pos + new Vector3(-size, size, 0);
        }
        else if (vIndex == 2)
        {
            m_Positions[index ] = p.pos + new Vector3(size, -size, 0);
        }
        else if (vIndex == 3)
        {
            m_Positions[index] = p.pos + new Vector3(size, size, 0);
        }
    }
}
