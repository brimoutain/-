using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChessMove : MonoBehaviour
{
    private Vector3 mousePos;
    public Chess chess;
    protected bool isDraging = false;
    public bool first;
    private void Update()
    {
        if (isDraging)
        {
            mousePos = Camera.main.ScreenToWorldPoint(Input.mousePosition);
            transform.position = new Vector3(mousePos.x,mousePos.y,0.0f);
        }
    }
    private void OnMouseDown()
    {
        if (!chess.player && first)
        {
            isDraging = true;
        }else if (chess.player && !first)
        {
            isDraging = true;
        }
    }

    private void OnMouseUp()
    {
        if (isDraging)
        {
            isDraging = false;
            chess.player = !chess.player;
        }
    }

    protected virtual void OnCollisionEnter2D(Collision2D collision)
    {

        if(collision.gameObject.tag == "Chess")
        {
            Destroy(collision.gameObject);
        }
    }

}
