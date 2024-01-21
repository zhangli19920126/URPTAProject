using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class VectorExtension 
{
    public static Vector3 ProjectOntoPlane(this Vector3 vector, Vector3 planeNormal)
    {
        return (vector - Vector3.Dot(vector, planeNormal) * planeNormal);
    }
}
