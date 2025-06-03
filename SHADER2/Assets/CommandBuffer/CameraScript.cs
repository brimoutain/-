using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraScript : PostEffect
{
    Camera cam;
    RenderTexture blurRT;
    public Material blurMaterial;

    [Range(0, 4)]
    public int iteration = 0;
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    [Range(1, 8)]
    public int dowmSample = 2;


    void Start()
    {
        Debug.Log("Start");
        cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.Depth;

        blurRT = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGB32);
        blurRT.Create();
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (blurMaterial != null)
        {
            blurMaterial.SetTexture("_MainTex", src);
            RenderTexture temp = RenderTexture.GetTemporary(Screen.width, Screen.height, 0);

            // 垂直模糊（Pass 0）
            Graphics.Blit(src, temp, blurMaterial, 0);

            // 水平模糊（Pass 1）
            Graphics.Blit(temp, blurRT, blurMaterial, 1);

            RenderTexture.ReleaseTemporary(temp);

            // 设置全局纹理供其他 shader 用
            Shader.SetGlobalTexture("_BlurTex", blurRT);
        }

    }

    void OnGUI()
    {
        if (blurRT != null)
        {
            // 在屏幕左上角显示一个 256x256 的小窗口预览模糊纹理
            GUI.DrawTexture(new Rect(10, 10, 256, 256), blurRT, ScaleMode.ScaleToFit, false);
        }
    }
}

