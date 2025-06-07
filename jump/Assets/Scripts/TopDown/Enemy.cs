using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Scripting.APIUpdating;

public class Enemy : MonoBehaviour
{
    public float speed = 1.5f;
    public float fireCD = 1f;

    Vector3 input;
    Transform player;
    bool isDead = false;
    Weapon weapon;
    public int weaponType;

    private void Start()
    {
        player = GameObject.Find("Player").transform;
        weapon = GetComponent<Weapon>();
        weapon.weaponType = weaponType;
    }

    private void Update()
    {
        Move();
        Fire();
    }

    private void Fire()
    {
        weapon.Fire(true,true);
    }

    private void Move()
    {
        input = player.position - transform.position;
        input = input.normalized;
        transform.position += input * speed * Time.deltaTime;
        transform.right = input;
    }
}
