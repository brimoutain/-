using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class SimplePool : MonoBehaviour
{
    Queue<GameObject> queue = new Queue<GameObject>();

    GameObject prefab;

    private string path = "Prefab";

    int maxNum = 10;

    public GameObject Create()
    {
        GameObject go;
        if (prefab == null)
        {
            prefab = Resources.Load(path) as GameObject;
        }
        if(queue.Count > 0)
        {
            go = queue.Dequeue();
            go.SetActive(true);
            return go;
        }
        else
        {
            go = Instantiate(prefab);
        }
        return go;
    }

    public void Destroy(GameObject go)
    {
        if (queue.Count < maxNum)
        {
            go.SetActive(false);
            queue.Enqueue(go);
            go.transform.SetParent(transform);
        }
        else
        {
            UnityEngine.Object.Destroy(go);
        }
    }
}
