

using UnityEditor;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using Vector3 = UnityEngine.Vector3;


public class NormalTools 
{
    [MenuItem("TA/法线平滑并写入切线")]
    private static void SmoothAllNormalWriteTangent()
    {
        MeshFilter[] meshFilters = Selection.activeGameObject.GetComponentsInChildren<MeshFilter>();
        foreach (var filter in meshFilters)
        {
            var mesh = filter.sharedMesh;
            SmoothAndWriteMeshNormalToTangent(mesh);
        }
        
        var skinnedMeshRenderers = Selection.activeGameObject.GetComponentsInChildren<SkinnedMeshRenderer>();
        foreach (var skinnedMesh in skinnedMeshRenderers)
        {
            var mesh = skinnedMesh.sharedMesh;
            SmoothAndWriteMeshNormalToTangent(mesh);
        }
        
        Debug.Log("Done:法线平滑并写入切线");
    }

    private static void SmoothAndWriteMeshNormalToTangent(Mesh mesh)
    {
        var vertex2normals = new Dictionary<Vector3, Vector3>();
        for (int i = 0; i < mesh.vertexCount; i++)
        {
            var vertex = mesh.vertices[i];
            if (vertex2normals.ContainsKey(vertex))
            {
                vertex2normals[vertex] += mesh.normals[i];
            }
            else
            {
                vertex2normals.Add(vertex, mesh.normals[i]);
            }
        }

        bool hasTangent = mesh.tangents.Length == mesh.vertexCount;
        var tangents = hasTangent ? mesh.tangents : new Vector4[mesh.vertexCount];
        for (int i = 0; i < tangents.Length; i++)
        {
            var average = vertex2normals[mesh.vertices[i]].normalized;
            tangents[i] = new Vector4(average.x, average.y, average.z, 0f);
        }

        mesh.tangents = tangents;

        SaveMesh(mesh, mesh.name + "_SmoothNormalToTangent");
    }

    private static void SaveMesh(Mesh mesh, string name, bool makeNewInstance = true, bool optimizeMesh = true)
    {
        string path = EditorUtility.SaveFilePanel("Save Separate Mesh Asset", "Assets/", name, "asset");
        if(string.IsNullOrEmpty(path)) return;
        path = FileUtil.GetProjectRelativePath(path);
        var meshToSave = makeNewInstance ? Object.Instantiate(mesh) as Mesh : mesh;
        if(optimizeMesh) MeshUtility.Optimize(meshToSave);
        AssetDatabase.CreateAsset(meshToSave, path);
        AssetDatabase.SaveAssets();
    }

}
