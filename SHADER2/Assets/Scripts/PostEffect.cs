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
        // ȷ�� shader ��Ϊ��
        if (shader == null)
        {
            Debug.LogError("Shader Ϊ�գ������Ƿ��� Inspector ��帳ֵ��");
            return null;
        }

        // Shader �Ƿ���֧��
        if (!shader.isSupported)
        {
            Debug.LogError($"Shader {shader.name} �ڵ�ǰƽ̨����֧�֣�");
            return null;
        }

        // ��������Ѵ�����ʹ����ͬ�� Shader����ֱ�ӷ���
        if (material != null && material.shader == shader)
        {
            return material;
        }

        // �����²���
        material = new Material(shader);
        material.hideFlags = HideFlags.DontSave;

        return material;
    }

}
