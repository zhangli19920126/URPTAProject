using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class NormalTools 
{
    [MenuItem("TA/Tools/法线平滑写入切线")]
    private static void SelectGameobjectNormalSmoothIntoTangent()
    {
        var meshFilters = Selection.activeGameObject.GetComponentsInChildren<MeshFilter>();
        foreach (var filter in meshFilters)
        {
            WirteNormalSmoothIntoTangent(filter.sharedMesh);
        }
        
        var skinMeshes = Selection.activeGameObject.GetComponentsInChildren<SkinnedMeshRenderer>();
        foreach (var skinMesh in skinMeshes)
        {
            WirteNormalSmoothIntoTangent(skinMesh.sharedMesh);
        }
    }
    
    [MenuItem("TA/Tools/法线平滑写入顶点色")]
    private static void SelectGameobjectNormalSmoothIntoVertex()
    {
        var meshFilters = Selection.activeGameObject.GetComponentsInChildren<MeshFilter>();
        foreach (var filter in meshFilters)
        {
            WirteNormalSmoothIntoVertex(filter.sharedMesh);
        }
        
        var skinMeshes = Selection.activeGameObject.GetComponentsInChildren<SkinnedMeshRenderer>();
        foreach (var skinMesh in skinMeshes)
        {
            WirteNormalSmoothIntoVertex(skinMesh.sharedMesh);
        }
    }

    /// <summary>
    /// 1.用dictionary存储顶点 -> 法线
    /// 2.遍历所有顶点，将顶点法线进行累加，然后normalize并存入切线
    /// </summary>
    private static void WirteNormalSmoothIntoTangent(Mesh mesh)
    {
        if(mesh == null) return;
        var vertexCount = mesh.vertexCount;
        var dir = new Dictionary<Vector3, Vector3>();
        for (int i = 0; i < vertexCount; i++)
        {
            var vertex = mesh.vertices[i];
            var normal = mesh.normals[i];
            if (dir.ContainsKey(vertex))
            {
                dir[vertex] += normal;
            }
            else
            {
                dir.Add(vertex, normal);
            }
        }

        var tagents = mesh.tangents.Length == vertexCount ? mesh.tangents : new Vector4[vertexCount];
        for (int i = 0; i < vertexCount; i++)
        {
            var normalAvg = dir[mesh.vertices[i]].normalized;
            tagents[i] = new Vector4(normalAvg.x, normalAvg.x, normalAvg.z, 0);
        }

        mesh.tangents = tagents;
        
        SaveMesh(mesh, mesh.name + "_smoothNormalToTangent", true, true);
    }
    
    /// <summary>
    /// 1.用dictionary存储顶点 -> 法线
    /// 2.遍历所有顶点，将顶点法线进行累加，然后normalize并存入切线
    /// 3.从法线映射到颜色需要： *0.5+0.5
    /// </summary>
    private static void WirteNormalSmoothIntoVertex(Mesh mesh)
    {
        if(mesh == null) return;
        var vertexCount = mesh.vertexCount;
        var dir = new Dictionary<Vector3, Vector3>();
        for (int i = 0; i < vertexCount; i++)
        {
            var vertex = mesh.vertices[i];
            var normal = mesh.normals[i];
            if (dir.ContainsKey(vertex))
            {
                dir[vertex] += normal;
            }
            else
            {
                dir.Add(vertex, normal);
            }
        }

        var colors = mesh.colors.Length == vertexCount ? mesh.colors : new Color[vertexCount];
        for (int i = 0; i < vertexCount; i++)
        {
            var normalAvg = dir[mesh.vertices[i]].normalized;
            colors[i] = new Color(normalAvg.x * 0.5f + 0.5f, normalAvg.x * 0.5f + 0.5f, normalAvg.z * 0.5f + 0.5f,  0.0f);
        }

        mesh.colors = colors;
        
        SaveMesh(mesh, mesh.name + "_smoothNormalToTangent", true, true);
    }
    
    private static void SaveMesh(Mesh mesh, string name, bool makeNewInstance, bool optimizeMesh)
    {
        string path = EditorUtility.SaveFilePanel("Save Separate Mesh Asset", "Assets/", name, ".asset");
        if(string.IsNullOrEmpty(path)) return;

        path = FileUtil.GetProjectRelativePath(path);

        var meshNew = makeNewInstance ? Object.Instantiate(mesh) as Mesh : mesh;
        
        if(optimizeMesh) MeshUtility.Optimize(meshNew);
        
        AssetDatabase.CreateAsset(meshNew, path);
        AssetDatabase.SaveAssets();
    }
}
