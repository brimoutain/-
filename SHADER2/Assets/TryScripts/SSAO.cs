// SSAO.cs
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class SSAO : PostEffect
{
    public Shader ssaoShader;
    public Material ssaoMaterial;
    public Texture2D noiseTexture;

    [Range(16, 256)] public int sampleCount = 64;
    [Range(0.1f, 2.0f)] public float radius = 0.5f;
    [Range(0.0f, 4.0f)] public float intensity = 1.0f;
    [Range(0.0f, 0.1f)] public float bias = 0.025f;

    private Vector4[] sampleKernels = new Vector4[64];

    void OnEnable()
    {
        GenerateSampleKernels();
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    public Material material
    {
        get
        {
            if (ssaoMaterial == null) CheckShaderAndCreateMaterial(ssaoShader, ssaoMaterial);
            return ssaoMaterial;
        }
    }

    void GenerateSampleKernels()
    {
        for (int i = 0; i < sampleKernels.Length; i++)
        {
            Vector3 sample = Random.insideUnitSphere.normalized;
            sample *= Mathf.Lerp(0.1f, 1.0f, (float)i / sampleKernels.Length);
            sampleKernels[i] = new Vector4(sample.x, sample.y, sample.z, 0);
        }
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material == null)
        {
            Graphics.Blit(src, dest);
            return;
        }

        material.SetVectorArray("_SampleKernelArray", sampleKernels);
        material.SetTexture("_NoiseTex", noiseTexture);
        material.SetFloat("_Radius", radius);
        material.SetFloat("_Intensity", intensity);
        material.SetFloat("_Bias", bias);

        Graphics.Blit(src, dest, material);
    }

    // PostEffect基类需要包含以下方法
    // protected Material CheckShaderAndCreateMaterial(Shader shader, Material material) {
    //     if (!shader || !shader.isSupported) return null;
    //     if (material && material.shader == shader) return material;
    //     material = new Material(shader);
    //     material.hideFlags = HideFlags.DontSave;
    //     return material;
    // }
}