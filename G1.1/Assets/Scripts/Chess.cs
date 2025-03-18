using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class Chess : MonoBehaviour
{
    public bool player;
    public GameObject Player1;
    public GameObject Player2;

    private void Start()
    {
        player = false;
    }
}
