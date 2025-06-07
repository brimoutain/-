using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Wood : MonoBehaviour
{
    public float maxHp = 100;
    float currentHp;

    private void Start()
    {
        currentHp = maxHp;
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        if(collision.relativeVelocity.magnitude > 4f)
        {
            currentHp -= collision.relativeVelocity.magnitude * 10f;
        }
        if(currentHp <= 0)
        {
            Destroy(gameObject);
        } 
    }
}
