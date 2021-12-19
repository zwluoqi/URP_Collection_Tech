using Unity.Burst;
using Unity.Collections;
using Unity.Jobs;

[BurstCompile]
public struct MergeMeshIndicesJob:IJobParallelFor
{
    public NativeArray<int> m_Indices;

    public int mesh1VerticeLength;
    public int mesh1Indices;

    public void Execute(int index)
    {
        if (index >= mesh1Indices)
        {
            m_Indices[index] = m_Indices[index] + mesh1VerticeLength;
        }
        else
        {
            m_Indices[index] = m_Indices[index];
        }
    }
}