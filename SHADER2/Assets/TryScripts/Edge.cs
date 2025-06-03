using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Edge : PostEffect
{
    public Shader edgeShader;
    private Material edgeMaterial = null;

    public Material material
    {
        get
        {
            edgeMaterial = CheckShaderAndCreateMaterial(edgeShader, edgeMaterial);
            return edgeMaterial;
        }
    }

    [Range(0.0f, 1.0f)]
    public float edgeOnly = 0.0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;

    public float sampleDistance = 1.0f;

    public float sensitivityDepth = 1.0f;

    public float sensitivityNormals = 1.0f;

    private void OnEnable()
    {
        Camera cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.DepthNormals;
    }

    //只对不透明物体有用
    [ImageEffectOpaque]

    //只对不透明物体有用
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null)
        {
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgroundColor", backgroundColor);
            material.SetFloat("_SampleDistance", sampleDistance);
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0.0f, 0.0f));
            material.SetTexture("_CameraDepthNormalTexture", Shader.GetGlobalTexture("_CameraDepthNormalsTexture"));
            Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
