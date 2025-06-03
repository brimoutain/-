using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffect : MonoBehaviour
{
    protected void CheckResources()
    {
        bool isSupported = CheckSupport();

        if (isSupported == false)
        {
            NotSupported();
        }
    }

    protected bool CheckSupport()
    {


        return true;
    }

    protected void NotSupported()
    {
        enabled = false;
    }

    protected void Start()
    {
        CheckResources();
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        // 确保 shader 不为空
        if (shader == null)
        {
            Debug.LogError("Shader 为空，请检查是否在 Inspector 面板赋值！");
            return null;
        }

        // Shader 是否受支持
        if (!shader.isSupported)
        {
            Debug.LogError($"Shader {shader.name} 在当前平台不被支持！");
            return null;
        }

        // 如果材质已存在且使用相同的 Shader，则直接返回
        if (material != null && material.shader == shader)
        {
            return material;
        }

        // 创建新材质
        material = new Material(shader);
        material.hideFlags = HideFlags.DontSave;

        return material;
    }

}
