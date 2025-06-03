using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class WholeFog : PostEffect
{
    public Shader fogShader;
    public Material fogMaterial;

    private Material material
    {
        get
        {
            fogMaterial = CheckShaderAndCreateMaterial(fogShader,fogMaterial);
            return fogMaterial;
        }
    }

    private Camera mycamera;
    public Camera camera
    {
        get
        {
            if(mycamera == null)
            {
                mycamera = GetComponent<Camera>();
            }
            return mycamera;
        }
    }

    private Transform myCameraTransform;
    public Transform cameraTransform
    {
        get
        {
            if(myCameraTransform == null)
            {
                myCameraTransform = camera.transform;
            }
            return myCameraTransform;
        }
    }

    public float fogStart = 0.0f;
    public float fogEnd = 2.0f;

    [Range(0.0f,3.0f)]
    public float fogDensity = 1.0f;

    public Color fogColor = Color.white;


    public Texture2D noiseMap;
    [Range(0.0f,1.0f)]
    public float noiseAmount;

    private void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            Matrix4x4 frustumCorners = Matrix4x4.identity;

            float fov = camera.fieldOfView;
            float near = camera.nearClipPlane;
            float far = camera.farClipPlane;
            float aspect = camera.aspect;

            float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
            Vector3 toRight = cameraTransform.right * halfHeight * aspect;
            Vector3 toTop = cameraTransform.up * halfHeight;

            Vector3 topLeft = cameraTransform.forward * near + toTop - toRight;
            float scale = topLeft.magnitude / near;

            Vector3 topRight = cameraTransform.forward * near + toTop + toRight;
            topRight = topRight.normalized * scale;

            Vector3 buttonLeft = cameraTransform.forward * near - toTop - topRight;
            buttonLeft = buttonLeft.normalized * scale;

            Vector3 buttonRight = cameraTransform.forward * near + toRight - toTop;
            buttonRight = buttonRight.normalized * scale;

            frustumCorners.SetRow(0, buttonLeft);
            frustumCorners.SetRow(1, buttonRight);
            frustumCorners.SetRow(2, topRight);
            frustumCorners.SetRow(3, topLeft);

            material.SetMatrix("_FrustumCornersRay", frustumCorners);
            material.SetMatrix("_ViewProJectionInverseMartrix", (camera.projectionMatrix * camera.worldToCameraMatrix).inverse);

            material.SetFloat("_FogStart", fogStart);
            material.SetFloat("_FogEnd", fogEnd);
            material.SetFloat("_FogDistance", fogDensity);
            material.SetColor("_FogColor", fogColor);
            material.SetFloat("_NoiseAmount",noiseAmount);
            material.SetTexture("_NoiseMap", noiseMap);

            Graphics.Blit(source, destination, material );
        }
        else
            Graphics.Blit( source, destination);
    }
}
