using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Score : MonoBehaviour
{
    public int score;
    public Text text;

    private void Update()
    {
        text.text = "Score : " + score.ToString();
    }
}
