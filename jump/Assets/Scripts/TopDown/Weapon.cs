using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Weapon : MonoBehaviour
{
    public GameObject bulletPrefab;
    public float pistolFireCD = .5f;
    public float rifleFireCD = .1f;
    float lastFireTime;
    public int weaponType = 0;

    public void Fire(bool keyDown, bool keyPressed)
    {
        switch(weaponType)
        {
            case 0:
                if (keyDown)
                {
                    GunFire(pistolFireCD);
                }
                break;
            case 1:
                if (keyPressed)
                {
                    GunFire(rifleFireCD);
                }
                break;
            default:
                return;
        }
    }


    private void GunFire(float CD)
    {
        if(Time.time > lastFireTime + CD)
        {
            lastFireTime = Time.time;
            GameObject bullet = Instantiate(bulletPrefab,null);
            bullet.transform.position = transform.position + transform.right;
            bullet.transform.right = transform.right;
        }else
            return;
    }

    public void ChangeWeapon()
    {
        weaponType++;
        if(weaponType > 1)
        {
            weaponType = 0;
        }
    }
}
