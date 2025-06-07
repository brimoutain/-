using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Spawner : MonoBehaviour
{
    public GameObject circle;
    SimplePool pool;
    Vector3 mousePos;

    private void Start()
    {
        pool = GameObject.Find("Pool").GetComponent<SimplePool>();
    }

    private void Update()
    {
        mousePos = Camera.main.ScreenToWorldPoint(Input.mousePosition);

        Vector3 direction = mousePos - transform.position;
        transform.position = transform.position + direction;
        //for (int i = 0; i < 1; i++)
        //{
            //Instantiate(circle,transform.position,Quaternion.identity);
            GameObject go = pool.Create();
            Vector2 randDirection = Random.insideUnitCircle.normalized;
            go.GetComponent<Circle>().pool = pool;
            go.GetComponent<Circle>().startTime = Time.time;
            go.GetComponent<Rigidbody2D>().position = transform.position;
            go.GetComponent<Rigidbody2D>().velocity = randDirection * Random.Range(0.0f, 5.0f);
        //}
    }

}
