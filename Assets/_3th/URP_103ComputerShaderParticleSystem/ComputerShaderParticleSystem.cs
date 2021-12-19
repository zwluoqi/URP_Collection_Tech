using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ComputerShaderParticleSystem : MonoBehaviour
{

    #region Compute Shader
    public struct Particle
    {
        public Vector3 pos;
        public float active;
        public Vector3 dir;
        public float speed;
        public Color color;
        public float timer;
        public float life;
    }
    public struct Emit
    {
        public ComputeBuffer buffer;
        public Particle[] particleBuffers;
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
            particleBuffers = new Particle[particleCount];
            int stride = 0;
            unsafe
            {
                stride = sizeof(Particle);    
            }
            buffer = new ComputeBuffer(particleCount,stride);
        }

        public void EmitParticle(float delta)
        {
            particleEmitTimer += delta;
            if (particleEmitTimer - lastParticleEmitTimer > emitSpaceTimer)
            {
                var particleBuffer = particleBuffers[curParticleEmitIndex];
                
                particleBuffer.active = 1.0f;
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
            // particleBuffers.Dispose();
            buffer.Dispose();
        }
    }

    public ComputeShader shader;
    public float particleScale = 1;
    public float particleSpeed = 1;
    public float particleLift = 1;
    public float particleRadio = 0.1f;
    
    public Material material;

    private ComputeBuffer posBuffer;
    private Emit emit;
    private Vector3[] m_Positions;
    private Color[] m_Colors;
    private Vector2[] m_Uv0S;
    private int[] m_Indices;
    private Mesh mesh;
    #endregion

    private void Start()
    {
        emit.init(particleLift,particleSpeed,particleRadio);
        
        
        m_Positions = new Vector3[emit.particleBuffers.Length*4];
        posBuffer = new ComputeBuffer(emit.particleBuffers.Length*4,sizeof(float)*3);
        m_Colors = new Color[emit.particleBuffers.Length*4];
        m_Uv0S = new Vector2[emit.particleBuffers.Length*4];
        m_Indices = new int[emit.particleBuffers.Length*6];

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

        emit.buffer.SetData(emit.particleBuffers);
        int kernel = shader.FindKernel("CSMainParticle");
        shader.SetBuffer(kernel, "dataBuffer", emit.buffer);
        shader.Dispatch(kernel, emit.particleBuffers.Length, 1, 1);
        
        emit.buffer.GetData(emit.particleBuffers);

        posBuffer.SetData(m_Positions);
        kernel = shader.FindKernel("CSMainPos");
        shader.SetBuffer(kernel, "dataBuffer", emit.buffer);
        shader.SetBuffer(kernel, "m_Positions", posBuffer);
        shader.Dispatch(kernel, m_Positions.Length, 1, 1);
        
        posBuffer.GetData(m_Positions);
        
    }

    private void LateUpdate()
    {
        mesh.SetVertices(m_Positions);
        mesh.SetColors(m_Colors);
        mesh.RecalculateBounds();
        
        Graphics.DrawMesh(mesh,this.transform.localToWorldMatrix,material,0);
    }

    private void OnDestroy()
    {
        emit.Dispose();
        this.posBuffer.Dispose();
    }
}
