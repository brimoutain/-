using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Circle : MonoBehaviour
{
    public SimplePool pool;
    float lifeTime = 1.5f;
    public float startTime;

    private void Start()
    {
        startTime = Time.time;
        pool = GameObject.Find("Pool").GetComponent<SimplePool>();
    }
    void Update()
    {
        if(Time.time - startTime > lifeTime)
        {
            pool.Destroy(gameObject);
        }
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.CompareTag("Ground"))
        {
            collision.gameObject.GetComponent<Score>().score++;
        }
    }
}
