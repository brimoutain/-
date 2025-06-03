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

            //����������Ļ��С�Ļ�����
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            //�˲�ģʽ�ĳ�˫�����˲�
            buffer0.filterMode = FilterMode.Bilinear;

            //���õ�һ��pass
            Graphics.Blit(src, buffer0, material,0);

            //��forѭ����ͼ���˹ģ��
            for (int i = 0; i < iteration; i++)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread); // ����1�������ʼΪ0

                // ��ֱģ����Pass 1��
                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0); // ����2�����ֿ��һ��
                Graphics.Blit(buffer0, buffer1, material, 1);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;

                // ˮƽģ����Pass 2��
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(buffer0, buffer1, material, 2);
                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }
            //��ģ�����ͼ���shader
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
