using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using System;

public class ProtralScript : MonoBehaviour
{
    public Vector3 startScale;
    public Vector3 middleScale;
    public Vector3 endScale;

    public float time1;
    public float time2;

    private void Start()
    {
        transform.localScale = startScale;
        StartCoroutine(Open());
    }


    IEnumerator Open()
    {
        transform.DOScale(middleScale, time1);

        yield return new WaitForSeconds(time1-.1f);

        transform.DOScale(endScale, time2);
    }
}
