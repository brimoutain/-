// SSAO.shader
Shader "Unlit/SSAO"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("Noise Texture",2D) = "white" {}
        _Radius("Sample Radius", Range(0.1, 2.0)) = 0.5
        _Intensity("Intensity", Range(0, 4)) = 1.0
        _Bias("Bias", Range(0, 0.1)) = 0.025
    }
    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"
        
        sampler2D _CameraDepthNormalsTexture;
        sampler2D _MainTex;
        sampler2D _NoiseTex;
        float4 _NoiseTex_TexelSize;
        
        float _Radius;
        float _Intensity;
        float _Bias;
        
        static const int MAX_KERNEL_SIZE = 64;
        float4 _SampleKernelArray[MAX_KERNEL_SIZE];
        
        struct v2f {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float3 viewRay : TEXCOORD1;
        };

        v2f vert_AO(appdata_img v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            
            // 计算视图空间射线
            float3 viewRay = float3(
                (2.0 * o.uv.x - 1.0),
                (2.0 * o.uv.y - 1.0) * _ProjectionParams.z,
                _ProjectionParams.z
            );
            o.viewRay = mul(unity_CameraInvProjection, float4(viewRay, 1)).xyz;
            return o;
        }

        float3 ReconstructViewPos(float2 uv, float depth，v2f i) {
            return depth * normalize(i.viewRay);
        }

        fixed4 frag_AO(v2f i) : SV_TARGET {
            // 解码深度和法线
            float4 depthNormal = tex2D(_CameraDepthNormalsTexture, i.uv);
            float depth;
            float3 viewNormal;
            DecodeDepthNormal(depthNormal, depth, viewNormal);
            viewNormal = normalize(viewNormal) * float3(1, 1, -1);
            
            // 重建视图空间位置
            float3 viewPos = ReconstructViewPos(i.uv, depth,i);
            
            // 获取噪声纹理
            float2 noiseUV = i.uv * _ScreenParams.xy * _NoiseTex_TexelSize.xy;
            float3 randomVec = tex2D(_NoiseTex, noiseUV).xyz * 2.0 - 1.0;
            
            // 构建TBN矩阵
            float3 tangent = normalize(randomVec - viewNormal * dot(randomVec, viewNormal));
            float3 bitangent = cross(viewNormal, tangent);
            float3x3 TBN = float3x3(tangent, bitangent, viewNormal);
            
            // 计算环境光遮蔽
            float occlusion = 0.0;
            for(int k = 0; k < MAX_KERNEL_SIZE; k++) {
                float3 sampleOffset = mul(TBN, _SampleKernelArray[k].xyz);
                sampleOffset = viewPos + sampleOffset * _Radius;
                
                // 转换到屏幕空间
                float4 samplePos = mul(UNITY_MATRIX_P, float4(sampleOffset, 1));
                samplePos.xy = (samplePos.xy / samplePos.w) * 0.5 + 0.5;
                
                // 采样比较深度
                float sampleDepth = tex2Dlod(_CameraDepthNormalsTexture, float4(samplePos.xy, 0, 0)).w;
                float3 sampleViewPos = ReconstructViewPos(samplePos.xy, sampleDepth);
                
                // 范围检测和偏置
                float rangeCheck = smoothstep(0.0, 1.0, _Radius / abs(viewPos.z - sampleViewPos.z));
                occlusion += (sampleViewPos.z >= sampleOffset.z + _Bias) ? 1.0 * rangeCheck : 0.0;
            }
            
            occlusion = 1.0 - (occlusion / MAX_KERNEL_SIZE);
            return pow(occlusion, _Intensity);
        }
        ENDCG

        Pass {
            CGPROGRAM
            #pragma vertex vert_AO
            #pragma fragment frag_AO
            #pragma target 3.0
            ENDCG
        }
    }
}