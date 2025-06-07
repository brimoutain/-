using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    public float speed = 10f;
    public float lifeTime = 2f;
    float startTime;

    private void Start()
    {
        startTime = Time.time;
    }

    private void Update()
    {
        transform.position += transform.right * speed * Time.deltaTime;
        if(Time.time > startTime + lifeTime)
        {
            Destroy(gameObject);
        }
    }


    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.tag == "Enemy" || collision.gameObject.tag == "Player")
        {
            Destroy(collision.gameObject);
            Destroy(gameObject);
        }
    }

}
