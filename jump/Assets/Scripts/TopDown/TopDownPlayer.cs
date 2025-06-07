using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Scripting.APIUpdating;

public class TopDownPlayer : MonoBehaviour
{
    public float speed = 3;
    public float maxHp = 20;
    public float currentHp;
    bool isDead = false;
    Vector3 input;

    Weapon weapon;
    // Start is called before the first frame update
    void Start()
    {
        currentHp = maxHp;
        weapon = GetComponent<Weapon>();
    }

    // Update is called once per frame
    void Update()
    {
        input = new Vector3(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"),0);//有出溜效果
        if (!isDead)
        {
            Move();
            PlayerFire();
            if (Input.GetKeyDown(KeyCode.J))
                weapon.ChangeWeapon();
        }
    }

    private void PlayerFire()
    {
        weapon.Fire(Input.GetKeyDown(KeyCode.K),Input.GetKey(KeyCode.K));
    }

    private void Move()
    {
        input = input.normalized;
        transform.position += input * speed * Time.deltaTime;
        if(input.magnitude > 0.1f)
        {
            transform.right = input;
            //transform.right = new Vector3(GetComponent<Rigidbody2D>().velocity, 0);
        }
    }
}
