using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    public float speed = 1;
    // Update is called once per frame
    void LateUpdate()
    {
        transform.Rotate(new Vector3(0,speed * Time.deltaTime * 10, 0));
    }
}
