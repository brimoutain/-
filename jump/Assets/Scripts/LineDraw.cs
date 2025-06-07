using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LineDraw : MonoBehaviour
{
    public LineRenderer line; 
    public Transform birdTrans;
    public Transform point0Trans;
    public Transform point1Trans;
    public bool isDrawing;

    private void Start()
    {        
        line.positionCount = 3;
    }
    private void Update()
    {
        if (isDrawing)
        {
            line.SetPosition(0, point0Trans.position);
            line.SetPosition(1, birdTrans.position);
            line.SetPosition(2,point1Trans.position);
        }
    }

    public void StartDrawing()
    {
        line.enabled = true;
        isDrawing = true;
    }

    public void EndDrawing()
    {
        line.enabled = false;
        isDrawing = false;
    }
}
