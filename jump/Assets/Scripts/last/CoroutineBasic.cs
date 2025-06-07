using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CoroutineBasic : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(Timer());
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    IEnumerator Timer()
    {
        Debug.Log("start test");
        yield return new WaitForSeconds(1);
        Debug.Log(Time.time);
        yield return new WaitForSeconds(2);
        Debug.Log(Time.time);
    }
}
