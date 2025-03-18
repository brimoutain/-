using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Rule : MonoBehaviour
{
    public GameObject chess1;
    public GameObject chess2;
    public GameObject chess3;
    public GameObject chess4;

    private int chess = 1;
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            chess++;
        }
        switch (chess)
        {
            case 1:
                chess1.SetActive(true);
                break;
            case 2:
                chess1.SetActive(false);
                chess2.SetActive(true);
                break;
            case 3:
                chess2.SetActive(false);
                chess3.SetActive(true);
                break;
            case 4:
                chess3.SetActive(false);
                chess4.SetActive(true);
                break;
            case 5:
                SceneManager.LoadScene("SampleScene");
                break;
            default:
                return;
        }
    }
}
