using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PushBoxGame : MonoBehaviour
{
    public int score = 0;

    private void Update()
    {
        if(score == 2)
        {
            Debug.Log("Win");
        }
    }
}
