using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Jobs;
using Unity.Collections;
using Unity.Burst;
using Unity.Jobs;
using Unity.Mathematics;
using UnityEditor;


public class MeshGenerator : MonoBehaviour
{
    public Transform meshParent;
    public MeshFilter meshFilter1;
    public MeshFilter meshFilter2;
    

    public MeshFilter meshMergeFilter;
    
    
    private JobHandle meshMergeJobHandle;
    private MergeMeshJob meshMergeJob;

    private JobHandle meshMergeIndicesJobHandle;
    private MergeMeshIndicesJob meshIndicesMergeJob;

    private JobHandle mergeUVJobHandle;
    private MergeUVJob uvMergeJob;

    private NativeArray<Vector3> meshVertices;
    private NativeArray<Vector2> meshUV01s;
    private NativeArray<int> indices;

    private int[] m_Indices1;
    private int[] m_Indices2;

    private Vector3[] m_vertices1;
    private Vector3[] m_vertices2;
    
    private Vector2[] m_uv01_1;
    private Vector2[] m_uv01_2;

    
    private void Start()
    {
        coreCount = Mathf.Max(2,System.Environment.ProcessorCount-2);
        meshMergeFilter.sharedMesh = new Mesh();

        
        var mesh1 = meshFilter1.sharedMesh;
        var mesh2 = meshFilter2.sharedMesh;
        
        //make mesh as dynamic so unity can optimize sending vertex changes from cpu to gpu;
        mesh2.MarkDynamic();
        mesh1.MarkDynamic();
        
        
        
        m_Indices1 = mesh1.GetIndices(0);
        m_Indices2 = mesh2.GetIndices(0);

        m_vertices1 = mesh1.vertices;
        m_vertices2 = mesh2.vertices;

        m_uv01_1 = mesh1.uv;
        m_uv01_2 = mesh2.uv;
        
        
        
        meshVertices = new NativeArray<Vector3>(m_vertices1.Length+m_vertices2.Length,Allocator.Persistent);

        meshUV01s = new NativeArray<Vector2>(m_uv01_1.Length+m_uv01_2.Length,Allocator.Persistent);

        indices = new NativeArray<int>(m_Indices1.Length+m_Indices2.Length,Allocator.Persistent);
        
    }

    public int coreCount = 8;
    private void Update()
    {
        //
        // var mesh1 = meshFilter1.sharedMesh;
        // var mesh2 = meshFilter2.sharedMesh;
        //
        NativeArray<Vector3>.Copy(m_vertices1, meshVertices, m_vertices1.Length);
        NativeArray<Vector3>.Copy(m_vertices2,0, meshVertices,m_vertices1.Length, m_vertices2.Length);

        
        NativeArray<int>.Copy(m_Indices1, indices,m_Indices1.Length);
        NativeArray<int>.Copy(m_Indices2,0, indices,m_Indices1.Length, m_Indices2.Length);


        NativeArray<Vector2>.Copy(m_uv01_1, meshUV01s, m_uv01_1.Length);
        NativeArray<Vector2>.Copy(m_uv01_2,0, meshUV01s,m_uv01_1.Length, m_uv01_2.Length);




        meshMergeJob.meshVertices = meshVertices;
        meshMergeJob.translate1 = meshParent.transform.worldToLocalMatrix * meshFilter1.transform.localToWorldMatrix;
        meshMergeJob.translate2 = meshParent.transform.worldToLocalMatrix * meshFilter2.transform.localToWorldMatrix;
        meshMergeJob.mesh1Length = m_vertices1.Length;
        
        
        meshMergeJobHandle = meshMergeJob.Schedule<MergeMeshJob>(meshVertices.Length,
            (meshVertices.Length ) / (coreCount)  +1);


        meshIndicesMergeJob.mesh1VerticeLength = m_vertices1.Length;
        meshIndicesMergeJob.mesh1Indices = m_Indices1.Length;
        meshIndicesMergeJob.m_Indices = indices;
        

        meshMergeIndicesJobHandle = meshIndicesMergeJob.Schedule<MergeMeshIndicesJob>(indices.Length,
            (indices.Length) / (coreCount) +1);



        uvMergeJob.meshUV01s = meshUV01s;
        uvMergeJob.mesh1UVLength = m_uv01_1.Length;
        mergeUVJobHandle = uvMergeJob.Schedule<MergeUVJob>(meshUV01s.Length, meshUV01s.Length / coreCount + 1);
    }

    private void LateUpdate()
    {
        meshMergeJobHandle.Complete();
        meshMergeIndicesJobHandle.Complete();
        mergeUVJobHandle.Complete();
        

        meshMergeFilter.sharedMesh.SetVertices(meshMergeJob.meshVertices);
        meshMergeFilter.sharedMesh.SetUVs(0,uvMergeJob.meshUV01s);
        meshMergeFilter.sharedMesh.SetIndices(meshIndicesMergeJob.m_Indices, MeshTopology.Triangles,0);
        //
        meshMergeFilter.sharedMesh.RecalculateNormals();
    }


    private void OnDestroy()
    {
        meshVertices.Dispose();
        indices.Dispose();
        meshUV01s.Dispose();
    }
}

