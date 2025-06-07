using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PushBoxPlayer : MonoBehaviour
{
    public LayerMask mask;
    void Update()
    {
        Move();
    }

    private void Move()
    {
        if (Input.GetKeyUp(KeyCode.A))
        {
            if(CanMove(Vector3.left))
            transform.position += Vector3.left;
        }else if (Input.GetKeyUp(KeyCode.D))
        {
            if(CanMove(Vector3.right))
            transform.position += Vector3.right;
        }else if (Input.GetKeyUp(KeyCode.S))
        {
            if(CanMove(Vector3.down))
            transform.position += Vector3.down;
        }
        else if(Input.GetKeyUp(KeyCode.W))
        {
            if(CanMove(Vector3.up))
            transform.position += Vector3.up;
        }
    }
    
    bool CanMove(Vector3 direction)
    {
        RaycastHit2D[] hits = Physics2D.RaycastAll(transform.position, direction,1f,mask);
        if (hits.Length == 1)
            return true;
        else 
        {
            foreach (RaycastHit2D hit in hits)
            {
                if(hit.collider.CompareTag("Box"))
                   return hit.collider.GetComponent<Box>().Move(direction);
            }         
            return false;
        }
    }
}
