using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NPC : MonoBehaviour
{
    bool isPlayer;
    public GameObject image;
    void Update()
    {
        if (isPlayer)
        {
            if (Input.GetKeyDown(KeyCode.E) )
            {
                image.SetActive(true);
            }
            //else if (Input.GetKeyDown(KeyCode.Space))
            //{
            //    image.SetActive(false);
            //}
        }

        

    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.tag == "Player")
        {
            isPlayer = true;
        }
    }

    private void OnTriggerExit2D(Collider2D collision)
    {
        if (collision.gameObject.tag == "Player")
        {
            isPlayer = false;
        }
    }
}
