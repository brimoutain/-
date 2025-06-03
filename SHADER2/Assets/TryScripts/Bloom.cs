using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffect
{
    public Shader bloomShader;
    private Material bloomMaterial;

    public Material material
    {
        get
        {
            bloomMaterial = CheckShaderAndCreateMaterial(bloomShader, bloomMaterial);
            return bloomMaterial;
        }
    }

    [Range(0, 4)]
    public int iteration = 0;
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;
    [Range(1, 8)]
    public int dowmSample = 2;
    [Range(0,0.1f)]
    public float luminateThreshold = 0f;

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if(material != null)
        {
            material.SetFloat("_LuminateThreshold",luminateThreshold);
            int rtW = src.width / dowmSample;
            int rtH = src.height / dowmSample;

            //创建等于屏幕大小的缓冲区
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            //滤波模式改成双线性滤波
            buffer0.filterMode = FilterMode.Bilinear;

            //调用第一个pass
            Graphics.Blit(src, buffer0, material,0);

            //用for循环对图像高斯模糊
            for (int i = 0; i < iteration; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread); // 修正1：避免初始为0

                // 垂直模糊（Pass 1）
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0); // 修正2：保持宽高一致
                Graphics.Blit(buffer0, buffer1, material, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;

                // 水平模糊（Pass 2）
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, material, 2);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            //把模糊后的图像给shader
            material.SetTexture("_Bloom",buffer0);

            Graphics.Blit(src, dest, material,3);
            RenderTexture.ReleaseTemporary (buffer0);
        }
        else
        {
            Graphics.Blit(src , dest);
        }
    }
}
