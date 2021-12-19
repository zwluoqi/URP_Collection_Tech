using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeshGeneratorMainThread : MonoBehaviour
{
    
    public MeshFilter meshFilter1;
    public MeshFilter meshFilter2;
    
    public MeshFilter meshMergeFilter;

    
    
    
    private Vector3[] meshVertices;
    private int[] indices;
    
    // Start is called before the first frame update
    void Start()
    {
        meshMergeFilter.sharedMesh = new Mesh();

        
        var mesh1 = meshFilter1.mesh;
        var mesh2 = meshFilter2.mesh;
        
        
        var m_Indices1 = mesh1.GetIndices(0);
        var m_Indices2 = mesh2.GetIndices(0);

        indices = new int[m_Indices1.Length + m_Indices2.Length];
        
        Array.Copy(m_Indices1, indices,m_Indices1.Length);
        Array.Copy(m_Indices2,0, indices,m_Indices1.Length, m_Indices2.Length);

        var mesh1VerticeLength = mesh1.vertices.Length;
        var mesh1Indices = m_Indices1.Length;

        for (int index = 0; index < indices.Length; index++)
        {
            if (index >= mesh1Indices)
            {
                indices[index] = indices[index] + mesh1VerticeLength;
            }
            else
            {
                indices[index] = indices[index];
            }
        }
    }

    // Update is called once per frame
    void Update()
    {
        
        var mesh1 = meshFilter1.mesh;
        var mesh2 = meshFilter2.mesh;
        
        
        meshVertices = new Vector3[mesh1.vertices.Length+mesh2.vertices.Length];
        Array.Copy(mesh1.vertices, meshVertices, mesh1.vertices.Length);
        Array.Copy(mesh2.vertices,0, meshVertices,mesh1.vertices.Length, mesh2.vertices.Length);


        var translate1 = meshMergeFilter.transform.worldToLocalMatrix * meshFilter1.transform.localToWorldMatrix;
        var translate2 = meshMergeFilter.transform.worldToLocalMatrix * meshFilter2.transform.localToWorldMatrix;
        var mesh1Length = mesh1.vertices.Length;


        for (int index = 0; index < meshVertices.Length; index++)
        {
            if (index >= mesh1Length)
            {
                meshVertices[index] = translate2 * meshVertices[index];

            }
            else
            {
                meshVertices[index] = translate1 * meshVertices[index];
            }
        }
    }

    private void LateUpdate()
    {
        
        meshMergeFilter.sharedMesh.SetVertices(meshVertices);
        meshMergeFilter.sharedMesh.SetIndices(indices, MeshTopology.Triangles,0);
        //
        meshMergeFilter.sharedMesh.RecalculateNormals();
    }
}
