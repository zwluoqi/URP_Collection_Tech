using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Collections;
using Unity.Jobs;
using UnityEditor;
using UnityEngine;
using Random = Unity.Mathematics.Random;

public class JoySystemParticleSystem : MonoBehaviour
{

    
    public struct Particle
    {
        public Vector3 pos;
        public bool active;
        public Vector3 dir;
        public float speed;
        public Color color;
        public float timer;
        public float life;
    }
    public struct Emit
    {
        public NativeArray<Particle> particleBuffers;
        private int curParticleEmitIndex;
        private float particleEmitTimer;
        private float lastParticleEmitTimer;
        private float emitSpaceTimer;
        private float particleSpeed;
        private float life;
        public void init(float _life,float _particleSpeed,float _particleSpaceTime)
        {
            this.life = _life;
            this.particleSpeed = _particleSpeed;
            this.emitSpaceTimer = _particleSpaceTime;
            var particleCount = Mathf.CeilToInt( _life / _particleSpaceTime);
            particleCount = Mathf.Max(1, particleCount);
            particleBuffers = new NativeArray<Particle>(particleCount, Allocator.Persistent);
        }

        public void EmitParticle(float delta)
        {
            particleEmitTimer += delta;
            if (particleEmitTimer - lastParticleEmitTimer > emitSpaceTimer)
            {
                var particleBuffer = particleBuffers[curParticleEmitIndex];
                
                particleBuffer.active = true;
                Vector3 pos = new Vector3( UnityEngine.Random.Range(-10.0f,10.0f),0,UnityEngine.Random.Range(-10.0f,10.0f));
                Color color = new Color( UnityEngine.Random.Range(0,1.0f),
                    UnityEngine.Random.Range(0,1.0f),
                    UnityEngine.Random.Range(0,1.0f),
                    UnityEngine.Random.Range(0,1.0f));
                particleBuffer.color = color;
                particleBuffer.dir = new Vector3( UnityEngine.Random.Range(0,1.0f),UnityEngine.Random.Range(0,1.0f),UnityEngine.Random.Range(0,1.0f));
                particleBuffer.dir = particleBuffer.dir.normalized;
                particleBuffer.speed = particleSpeed+UnityEngine.Random.Range(0, particleSpeed);
                particleBuffer.life = life+UnityEngine.Random.Range(0, life);
                particleBuffer.pos = pos;
                particleBuffer.timer = 0;
                particleBuffers[curParticleEmitIndex] = particleBuffer;
                
                particleBuffers[curParticleEmitIndex] = particleBuffer;
                lastParticleEmitTimer = particleEmitTimer;
                curParticleEmitIndex++;
                if (curParticleEmitIndex >= particleBuffers.Length)
                {
                    curParticleEmitIndex = 0;
                }
            }
        }

        public void Dispose()
        {
            particleBuffers.Dispose();
        }
    }

    Emit emit;
    public float particleScale = 1;
    public float particleSpeed = 1;
    public float particleLift = 1;
    public float particleRadio = 0.1f;
    
    public int timer = 0;
    public Material material;
    
    private JobHandle jobHandle;
    private ParticlePosJob particlePosJob;
    private ParticleSystemJob particleSystemJob;
    private int coreCount = 2;

    Mesh mesh;
    public NativeArray<Vector3> m_Positions;

    public NativeArray<Color> m_Colors;
    public NativeArray<Vector2> m_Uv0S;
    public NativeArray<int> m_Indices;
    private void Start()
    {
        coreCount = Mathf.Max(2,System.Environment.ProcessorCount-2);
        emit.init(particleLift,particleSpeed,particleRadio);
        
        particleSystemJob.particles = emit.particleBuffers;
        particlePosJob.particles = emit.particleBuffers;
        
        m_Positions = new NativeArray<Vector3>(emit.particleBuffers.Length*4, Allocator.Persistent);

        m_Colors = new NativeArray<Color>(emit.particleBuffers.Length*4, Allocator.Persistent);
        m_Uv0S = new NativeArray<Vector2>(emit.particleBuffers.Length*4, Allocator.Persistent);
        m_Indices = new NativeArray<int>(emit.particleBuffers.Length*6, Allocator.Persistent);

        InitMesh();
    }

    void InitMesh()
    {
        mesh = new Mesh();
        var  size = 0.5f;
        for (int index = 0; index < emit.particleBuffers.Length; index++)
        {
            var p = emit.particleBuffers[index];
            var pos = emit.particleBuffers[index];
            //[1  3]
            //[0  2]
            m_Positions[index * 4 + 0] = p.pos + new Vector3(-size, -size, 0);
            m_Positions[index * 4 + 1] = p.pos + new Vector3(-size, size, 0);
            m_Positions[index * 4 + 2] = p.pos + new Vector3(size, -size, 0);
            m_Positions[index * 4 + 3] = p.pos + new Vector3(size, size, 0);

            m_Uv0S[index * 4 + 0] = new Vector2(0,0);
            m_Uv0S[index * 4 + 1] =  new Vector2(0,1);
            m_Uv0S[index * 4 + 2] =  new Vector2(1,0);
            m_Uv0S[index * 4 + 3] =  new Vector2(1,1);

            m_Indices[index * 6 + 0] = index * 4 + 0;
            m_Indices[index * 6 + 1] = index * 4 + 2;
            m_Indices[index * 6 + 2] = index * 4 + 3;

            m_Indices[index * 6 + 3] = index * 4 + 3;
            m_Indices[index * 6 + 4] = index * 4 + 1;
            m_Indices[index * 6 + 5] = index * 4 + 0;
        

            m_Colors[index * 4 + 0] = p.color;
            m_Colors[index * 4 + 1] = p.color;
            m_Colors[index * 4 + 2] = p.color;
            m_Colors[index * 4 + 3] = p.color;
        }
        mesh.SetVertices(m_Positions);
        mesh.SetColors(m_Colors);

        mesh.SetUVs(0,m_Uv0S);
        mesh.SetIndices(m_Indices, MeshTopology.Triangles ,0);
        mesh.RecalculateBounds();
    }

    private void Update()
    {
        emit.EmitParticle(Time.deltaTime);
        
        particleSystemJob.delta = Time.deltaTime;
        particleSystemJob.m_Positions = m_Positions;
        particleSystemJob.m_Colors = m_Colors;

        particlePosJob.delta = Time.deltaTime;

        var handle =  particlePosJob.Schedule<ParticlePosJob>(emit.particleBuffers.Length,
            (emit.particleBuffers.Length) / (coreCount) + 1);
        jobHandle = particleSystemJob.Schedule<ParticleSystemJob>(m_Positions.Length,
            (m_Positions.Length ) / (coreCount)  +1,handle);
        
        Graphics.DrawMesh(mesh,this.transform.localToWorldMatrix,material,0);
    }

    private void OnDrawGizmos()
    {
        Graphics.DrawMesh(mesh,this.transform.localToWorldMatrix,material,0);
    }

    private void LateUpdate()
    {
        jobHandle.Complete();
        
        mesh.SetVertices(m_Positions);
        mesh.SetColors(m_Colors);
        mesh.RecalculateBounds();
        
        // Graphics.DrawMesh(mesh,this.transform.localToWorldMatrix,material,0);
    }

    private void OnDestroy()
    {
        m_Positions.Dispose();
        m_Colors.Dispose();
        m_Indices.Dispose();
        m_Uv0S.Dispose();
        emit.Dispose();
    }
}

