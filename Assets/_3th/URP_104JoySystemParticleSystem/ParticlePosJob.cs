using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;
using Unity.Mathematics;
using UnityEngine;

[BurstCompile]
public struct ParticlePosJob:IJobParallelFor
{
    public NativeArray<JoySystemParticleSystem.Particle> particles;

    public float delta;
    public void Execute(int index)
    {
        var p = particles[index];
        p.timer += delta;
        if (p.timer > p.life)
        {
            p.active = false;
        }
        else
        {
            p.pos += p.dir * p.speed * delta;
        }
        particles[index] = p;
        
    }
}