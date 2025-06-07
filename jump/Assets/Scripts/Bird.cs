using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bird : MonoBehaviour
{
    public Vector3 mousePos;
    bool isDraging = false;
    private Rigidbody2D rb;
    bool isPrapared = false;
    public GameObject head;
    bool isSeted = false;

    public LineDraw lineDraw;
    public float radius;

    void Update()
    {
        if (isDraging)
        {
            mousePos = Camera.main.ScreenToWorldPoint(Input.mousePosition);//把屏幕二维坐标系转换为三维世界坐标                                                                         //transform.position = mousePos;摄像机z轴为-10，使用时会导致小球看不见

            Vector3 direction = mousePos - head.transform.position;
            if (direction.magnitude> radius)
            {
                direction = direction.normalized *radius;
            }
            transform.position = head.transform.position + direction;
        }
        if(isPrapared)
        {
            if(Input.GetMouseButtonDown(0)) 
                isSeted = true;
        }
    }

    private void Start()
    {
        rb = GetComponent<Rigidbody2D>();
    }

    private void OnMouseDown()
    {
        if (isPrapared)
        {
            if (isSeted)
            {
                //GetComponent<SpriteRenderer>().color = Color.red;
                isDraging = true;
            }
        }
        else
        {
            transform.position = head.transform.position + new Vector3(0, .8f, 0);
            isPrapared = true;
            lineDraw.StartDrawing();
            lineDraw.birdTrans = transform;
        }
    }

    private void OnMouseUp()
    {
        if (isDraging)
        {            
            //GetComponent<SpriteRenderer>().color = Color.blue;
            isDraging = false;
            rb.bodyType = RigidbodyType2D.Dynamic;
            Vector2 dir = head.transform.position - transform.position;
            rb.AddForce(dir*250);
            lineDraw.EndDrawing();
        }
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        if (collision.gameObject.tag == "Ground" && rb.velocity.magnitude <= .7f)
        {
            Destroy(gameObject);
        }
    }
}
