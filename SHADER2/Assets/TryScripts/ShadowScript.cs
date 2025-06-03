using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ShadowScript : PostEffect
{
    public Shader depthShader;
    public Camera lightCam;

    private RenderTexture depthRT;
    public GameObject cube;

    // Start is called before the first frame update
    void Start()
    {
        //创建shadowMap
        depthRT = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.ARGB32);
        //depthRT = new RenderTexture(Screen.width, Screen.height, 24, RenderTextureFormat.Depth);
        depthRT.Create();
        //设置光源相机
        lightCam.depthTextureMode = DepthTextureMode.Depth;
        lightCam.targetTexture = depthRT;
        lightCam.RenderWithShader(depthShader, null);
    }
    void Update()
    {
        if (lightCam && depthRT)
        {
            //设置全局matrix和阴影图
            Matrix4x4 WorldToCamClip = lightCam.projectionMatrix * lightCam.worldToCameraMatrix;
            Shader.SetGlobalMatrix("_ProjectionMV", WorldToCamClip);
            lightCam.targetTexture = depthRT;
            lightCam.RenderWithShader(depthShader, null);

            Shader.SetGlobalTexture("_ShadowMap", depthRT);
        }
    }

}
