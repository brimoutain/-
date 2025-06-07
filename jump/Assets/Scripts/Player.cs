using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using Unity.VisualScripting;
using UnityEngine;

public class Player : MonoBehaviour
{
    private float xInput;
    private float yInput;
    public float moveSpeed;
    public float jumpSpeed;

    private bool jumpAbility =true;
    private int jumpCount = 0;
    public float jumpTime = 0;
    public float jumpInterval;

    public Rigidbody2D rb;
    private bool isJumped = false;
    private float startTime;

    public GameObject EYE;
    public GameObject BYE;
    public GameObject BYEText;

    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        xInput = Input.GetAxisRaw("Horizontal");
        yInput = Input.GetAxisRaw("Vertical");


        if (xInput != 0)
        {
            rb.velocity = new Vector2(xInput * moveSpeed, rb.velocity.y);
        }
        else rb.velocity = new Vector2 (0, rb.velocity.y);
        if (Input.GetKeyDown(KeyCode.Space))
        {
            jumpCount++;
            if(isJumped) 
                jumpTime = Time.time - startTime -jumpInterval;
            JumpCheck();
            if (jumpAbility == true)
            {
                rb.velocity = new Vector2(rb.velocity.x, jumpSpeed);
            }
            OnJump();
        }
    }

    private void OnJump()
    {
        isJumped=true;
        startTime = Time.time;
    }

    private void JumpCheck()
    {
        if (jumpTime >= 0 && isJumped ==true)
        {
            jumpCount = 1;
            jumpAbility = true;
        }
        else if(jumpCount <= 2)
        {
            jumpAbility = true;
        }
        else if(jumpCount >=3)
        {
            jumpAbility = false;
        }
    }

    private void OnCollisionEnter2D(Collision2D collision)
    {
        if(collision.gameObject.tag == "Coin")
        {
            Destroy(collision.gameObject);
        }
        if(collision.gameObject.tag == "Enemy")
        {
            Destroy(gameObject);
        }
        if(collision.gameObject.tag == "Final")
        {
            EYE.SetActive(false);
            BYE.SetActive(true);
            BYEText.SetActive(true);
        }
    }

}
