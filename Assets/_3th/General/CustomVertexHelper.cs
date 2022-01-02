
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CustomVertexHelper:IDisposable
{
    private List<Vector3> m_Positions;
    private List<Vector3> m_Normals;
    private List<Vector4> m_Tangents;
    private List<Color32> m_Colors;
    private List<Vector2> m_Uv0S;
    private List<int> m_Indices;

    private bool m_ListsInitalized = false;




    /// <summary>
    /// Current number of vertices in the buffer.
    /// </summary>
    public int currentVertCount
    {
        get { return m_Positions != null ? m_Positions.Count : 0; }
    }

    private void InitializeListIfRequired()
    {
        if (!m_ListsInitalized)
        {
            m_Positions = ListPool<Vector3>.Get();
            m_Normals = ListPool<Vector3>.Get();
            m_Tangents= ListPool<Vector4>.Get();
            m_Colors = ListPool<Color32>.Get();
            m_Uv0S = ListPool<Vector2>.Get();
            m_Indices = ListPool<int>.Get();
            m_ListsInitalized = true;
        }
    }

    /// <summary>
    /// Cleanup allocated memory.
    /// </summary>
    public void Dispose()
    {
        if (m_ListsInitalized)
        {
            ListPool<Vector3>.Release(m_Positions);
            ListPool<Vector3>.Release(m_Normals);
            ListPool<Vector4>.Release(m_Tangents);

            ListPool<Color32>.Release(m_Colors);
            ListPool<Vector2>.Release(m_Uv0S);
            ListPool<int>.Release(m_Indices);

            m_Positions = null;
            m_Colors = null;
            m_Uv0S = null;
            m_Indices = null;
            m_Normals = null;
            m_Tangents = null;

            m_ListsInitalized = false;
        }
    }

    /// <summary>
    /// Add a single vertex to the stream.
    /// </summary>
    /// <param name="position">Position of the vert</param>
    /// <param name="color">Color of the vert</param>
    /// <param name="uv0">UV of the vert</param>
    public void AddVert(Vector3 position, Color32 color, Vector2 uv0)
    {
        // AddVert(position, color, uv0, Vector2.zero, s_DefaultNormal, s_DefaultTangent);

        InitializeListIfRequired();

        m_Positions.Add(position);
        m_Colors.Add(color);
        m_Uv0S.Add(uv0);
    }

    public void AddVert(Vector3 position, Vector3 normal,Vector4 tangent, Vector2 uv0)
    {
        // AddVert(position, color, uv0, Vector2.zero, s_DefaultNormal, s_DefaultTangent);

        InitializeListIfRequired();

        m_Positions.Add(position);
        this.m_Normals.Add(normal);
        this.m_Tangents.Add(tangent);
        m_Uv0S.Add(uv0);
    }

    /// <summary>
    /// Add a triangle to the buffer.
    /// </summary>
    /// <param name="idx0">index 0</param>
    /// <param name="idx1">index 1</param>
    /// <param name="idx2">index 2</param>
    public void AddTriangle(int idx0, int idx1, int idx2)
    {
        InitializeListIfRequired();

        m_Indices.Add(idx0);
        m_Indices.Add(idx1);
        m_Indices.Add(idx2);
    }


    /// <summary>
    /// Clear all vertices from the stream.
    /// </summary>
    public void Clear()
    {
        // Only clear if we have our lists created.
        if (m_ListsInitalized)
        {
            m_Positions.Clear();
            m_Colors.Clear();
            m_Uv0S.Clear();
            m_Indices.Clear();
            m_Normals.Clear();
            m_Tangents.Clear();
        }
    }


    /// <summary>
    /// Fill the given mesh with the stream data.
    /// </summary>
    public void FillMesh(Mesh mesh)
    {
        InitializeListIfRequired();

        mesh.Clear();

        if (m_Positions.Count >= 65000)
            throw new ArgumentException("Mesh can not have more than 65000 vertices");

        mesh.SetVertices(m_Positions);
        mesh.SetColors(m_Colors);
        mesh.SetUVs(0, m_Uv0S);
        mesh.SetTriangles(m_Indices, 0);
        mesh.RecalculateBounds();
    }

    /// <summary>
    /// Fill the given mesh with the stream data.
    /// </summary>
    public void FillMeshNormal(Mesh mesh)
    {
        InitializeListIfRequired();

        mesh.Clear();

        if (m_Positions.Count >= 65000)
            throw new ArgumentException("Mesh can not have more than 65000 vertices");

        mesh.SetVertices(m_Positions);
        mesh.SetNormals(m_Normals);
        mesh.SetTangents(m_Tangents);
        mesh.SetUVs(0, m_Uv0S);
        mesh.SetTriangles(m_Indices, 0);
        mesh.RecalculateBounds();
    }
}
