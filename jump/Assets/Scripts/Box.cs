using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Box : MonoBehaviour
{
    public LayerMask mask;
    public bool Move(Vector3 direction)
    {
        RaycastHit2D[] hits = Physics2D.RaycastAll(transform.position, direction,1f,mask);

        if(hits.Length == 1)
        {
            transform.position += direction;
            return true;
        }
        else
        {
            return false;
        }
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if(collision.gameObject.tag == "Target")
        {
            GameObject.Find("GameManager").GetComponent<PushBoxGame>().score++;
        }
    }

    private void OnTriggerExit2D(Collider2D collision)
    {
        if (collision.gameObject.tag == "Target")
        {
            GameObject.Find("GameManager").GetComponent<PushBoxGame>().score--;
        }
    }
}
