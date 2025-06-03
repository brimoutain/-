using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using static Unity.VisualScripting.Member;

public class Shadow : PostEffect
{
    public Camera lightCam;
    public Shader depthShader;
    private RenderTexture depthRT;
    private Material depthMaterial;

    private Material material
    {
        get
        {
            if (depthMaterial == null)
            {
                depthMaterial = CheckShaderAndCreateMaterial(depthShader, depthMaterial);
            }
            return depthMaterial;
        }
    }
    
    private Matrix4x4 WorldToCamClip
    {
        get
        {
            // 视图矩阵：World -> Camera Space
            Matrix4x4 viewMatrix = lightCam.worldToCameraMatrix;
            // 投影矩阵：Camera -> Clip Space
            Matrix4x4 projection = GL.GetGPUProjectionMatrix(lightCam.projectionMatrix, false);
            return projection * viewMatrix;
        }
    }

    private void Start()
    {
        lightCam.clearFlags = CameraClearFlags.Depth;  // 或者 CameraClearFlags.SolidColor
        lightCam.backgroundColor = Color.black;
        lightCam.depthTextureMode = DepthTextureMode.Depth;
        depthRT = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.RFloat);
        depthRT.Create();
    }

    private void LateUpdate()
    {
        if (lightCam && depthRT)
        {
            lightCam.targetTexture = depthRT;
            lightCam.RenderWithShader(depthShader, "RenderType");
            lightCam.targetTexture = null;
            Shader.SetGlobalTexture("_ShadowMap", depthRT);
            Shader.SetGlobalMatrix("_ProjectionMV", WorldToCamClip);
        }
    }

    // 新增方法
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material != null && depthRT != null)
        {
            Graphics.Blit(depthRT, dest);
            //Graphics.Blit(src, dest, material);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }

    //private void OnDestroy()
    //{
    //    if (depthRT != null)
    //    {
    //        depthRT.Release();
    //        Destroy(depthRT);
    //    }
    //}
}
