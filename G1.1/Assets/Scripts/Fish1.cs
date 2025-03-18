using System.Collections;
using System.Collections.Generic;
using System.Net.NetworkInformation;
using UnityEngine;

public class Fish : ChessMove
{
    public GameObject hole1;
    public GameObject hole2;
    protected override void OnCollisionEnter2D(Collision2D collision)
    {
        base.OnCollisionEnter2D(collision);
        if(collision.gameObject.tag == "Hole")
        {
        isDraging = false;
            transform.position = hole2.transform.position;
        }else if(collision.gameObject.tag == "HoleAnother")
        {
            isDraging = false;
            transform.position = hole1.transform.position;
        }
    }
}
