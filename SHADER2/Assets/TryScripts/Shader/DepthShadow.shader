Shader "Custom/DepthShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ShadowMap ("Shadow Map", 2D) = "white" {}
        _ShadowStrength ("Shadow Strength", Range(0, 1)) = 0.8
        _ShadowBias ("Shadow Bias", Range(0, 0.1)) = 0.005
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 shadowCoord : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _ShadowMap;
            float4 _MainTex_ST;
            float4x4 _ProjectionMV;
            float _ShadowStrength;
            float _ShadowBias;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                // 计算阴影坐标
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.shadowCoord = mul(_ProjectionMV, worldPos);
                
                return o;
            }

            float GetShadow(float4 shadowCoord)
            {
                // 将阴影坐标转换到[0,1]范围
                float3 projCoords = shadowCoord.xyz / shadowCoord.w;
                projCoords = projCoords * 0.5 + 0.5;
                
                // 检查是否在阴影贴图范围内
                if (projCoords.z > 1.0 || projCoords.x < 0.0 || projCoords.x > 1.0 || 
                    projCoords.y < 0.0 || projCoords.y > 1.0)
                    return 1.0;
                
                // 采样阴影贴图
                float shadowDepth = tex2D(_ShadowMap, projCoords.xy).r;
                float currentDepth = projCoords.z;
                
                // 应用阴影偏移并比较深度
                float shadow = currentDepth - _ShadowBias > shadowDepth ? _ShadowStrength : 1.0;
                
                return shadow;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float shadow = GetShadow(i.shadowCoord);
                return col * shadow;
            }
            ENDCG
        }
    }
} 