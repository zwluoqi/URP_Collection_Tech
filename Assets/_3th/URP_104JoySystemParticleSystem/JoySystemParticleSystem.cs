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
        public Vector3 dir;
        public float speed;
        public Color color;
        public float life;
    }
    public struct Emit
    {
        public NativeArray<Particle> particleBuffers;

        public void init(int particleCount,float life)
        {
            particleBuffers = new NativeArray<Particle>(particleCount, Allocator.Persistent);
            Vector3 pos = new Vector3( UnityEngine.Random.Range(-10.0f,10.0f),0,UnityEngine.Random.Range(-10.0f,10.0f));
            Color color = new Color( UnityEngine.Random.Range(0,life)/life,
                UnityEngine.Random.Range(0,10.0f)/life,
                UnityEngine.Random.Range(0,10.0f)/life,
                UnityEngine.Random.Range(0,10.0f)/life);
            var p = new Particle();
            for (int i = 0; i < particleCount; i++)
            {
                p.pos = pos;
                p.color = color;
                p.dir = new Vector3( UnityEngine.Random.Range(0,1.0f),UnityEngine.Random.Range(0,1.0f),UnityEngine.Random.Range(0,1.0f));
                p.dir = p.dir.normalized;
                p.speed = UnityEngine.Random.Range(0, 1.0f);
                particleBuffers[i] = p;
            }
        }

        public void Dispose()
        {
            particleBuffers.Dispose();
        }
    }

    Emit emit;
    public int particleCount = 10;
    public int life = 256;
    public int timer = 0;
    public Material material;
    
    private JobHandle jobHandle;
    private ParticleSystemJoy particleSystemJoy;
    private int coreCount = 2;

    Mesh mesh;
    public NativeArray<Vector3> m_Positions;
    // public NativeArray<Vector3> m_Normals;
    public NativeArray<Color32> m_Colors;
    public NativeArray<Vector2> m_Uv0S;
    public NativeArray<int> m_Indices;
    private void Start()
    {
        coreCount = Mathf.Max(2,System.Environment.ProcessorCount-2);
        emit.init(particleCount,life);
        
        particleSystemJoy.particles = emit.particleBuffers;
        m_Positions = new NativeArray<Vector3>(particleCount*4, Allocator.Persistent);

        m_Colors = new NativeArray<Color32>(particleCount*4, Allocator.Persistent);
        m_Uv0S = new NativeArray<Vector2>(particleCount*4, Allocator.Persistent);
        m_Indices = new NativeArray<int>(particleCount*6, Allocator.Persistent);

        InitMesh();
    }

    void InitMesh()
    {
        mesh = new Mesh();
        var  size = 0.5f;
        for (int index = 0; index < particleCount; index++)
        {
            var p = emit.particleBuffers[index];

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
        particleSystemJoy.delta = Time.deltaTime;

        particleSystemJoy.m_Positions = m_Positions;

        
        jobHandle = particleSystemJoy.Schedule<ParticleSystemJoy>(m_Positions.Length,
            (m_Positions.Length ) / (coreCount)  +1);
        
        Graphics.DrawMesh(mesh,this.transform.localToWorldMatrix,material,0);

    }

    private void OnDrawGizmos()
    {
        Graphics.DrawMesh(mesh,this.transform.localToWorldMatrix,material,0);
    }

    private void LateUpdate()
    {
        jobHandle.Complete();
        
        mesh.SetVertices(particleSystemJoy.m_Positions);
        // mesh.SetColors(particleSystemJoy.m_Colors);
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

