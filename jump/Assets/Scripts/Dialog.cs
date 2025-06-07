using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Dialog : MonoBehaviour
{
    public Text text;
    public string[] dialongs;
    public int index = 0;

    private void OnEnable()
    {
        index = 0;
        text.text = dialongs[index];
    }
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.E))
        {
            index++;
            if (index >= dialongs.Length)
            {
                gameObject.SetActive(false);
                return;
            }
            text.text = dialongs[index];
        }
    }
}
