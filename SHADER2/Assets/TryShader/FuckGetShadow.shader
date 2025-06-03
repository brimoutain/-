// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/FuckGetShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _shadowBias("Bias",Float) = 0.05
        _shadowStrength("ShadowStrength",Range(0,1)) = 0.1
        _filterSize("FilterSize",Int) = 3
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 lightpos : TEXCOORD1;
                float4 wpos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ShadowMap;
            float4 _ShadowMap_TexelSize;
            float4x4 _ProjectionMV;
            float _shadowBias;
            float _shadowStrength;
            int _filterSize;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                //获取世界坐标
                o.wpos = mul(unity_ObjectToWorld,v.vertex);
                //转到光源ndc
                o.lightpos = mul(_ProjectionMV,o.wpos);
                o.lightpos.xyz /= o.lightpos.w;
                return o;
            }
            //已改为PCF
            float hardShadow(float depth, float2 uv)
            {
                float4 orignDepth = tex2D(_ShadowMap, uv);
                float sampleDepth = DecodeFloatRGBA(orignDepth);
                return (sampleDepth + _shadowBias) < depth ? _shadowStrength : 1;
            }

            float PCF(float depth, float2 uv, float filterSize)
            {
                float shadow = 0;
                //读取深度图的操作
                //sampleShadow = DecodeFloatRGBA(tex2D(_ShadowMap,uv));

                // 手动展开 3x3 的卷积核
                shadow += (DecodeFloatRGBA(tex2D(_ShadowMap, (uv + float2(0, 0) * _ShadowMap_TexelSize.xy))) + _shadowBias < depth) ? _shadowStrength : 1;
                shadow += (DecodeFloatRGBA(tex2D(_ShadowMap, (uv + float2(1, 0) * _ShadowMap_TexelSize.xy))) + _shadowBias < depth) ? _shadowStrength : 1;
                shadow += (DecodeFloatRGBA(tex2D(_ShadowMap, (uv + float2(-1, 0) * _ShadowMap_TexelSize.xy)))+ _shadowBias < depth) ? _shadowStrength : 1;
                shadow += (DecodeFloatRGBA(tex2D(_ShadowMap, (uv + float2(0, 1) * _ShadowMap_TexelSize.xy))) + _shadowBias < depth) ? _shadowStrength : 1;
                shadow += (DecodeFloatRGBA(tex2D(_ShadowMap, (uv + float2(0, -1) * _ShadowMap_TexelSize.xy))) + _shadowBias < depth) ? _shadowStrength : 1;
                shadow += (DecodeFloatRGBA(tex2D(_ShadowMap, (uv + float2(1, 1) * _ShadowMap_TexelSize.xy))) + _shadowBias < depth) ? _shadowStrength : 1;
                shadow += (DecodeFloatRGBA(tex2D(_ShadowMap, (uv + float2(-1, 1) * _ShadowMap_TexelSize.xy))) + _shadowBias < depth) ? _shadowStrength : 1;
                shadow += (DecodeFloatRGBA(tex2D(_ShadowMap, (uv + float2(1, -1) * _ShadowMap_TexelSize.xy))) + _shadowBias < depth) ? _shadowStrength : 1;
                shadow += (DecodeFloatRGBA(tex2D(_ShadowMap, (uv + float2(-1, -1) * _ShadowMap_TexelSize.xy))) + _shadowBias < depth) ? _shadowStrength : 1;

                return shadow / 9.0; // 3x3核的平均
            }


            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                //OPGL下的NDC为(-1,1),我们转到0-1
                float2 shadowUV = i.lightpos.xy * 0.5 + 0.5;
                //防止越界
                if(i.lightpos.x > 1 || i.lightpos.x < 0 || i.lightpos.y > 1 || i.lightpos.y < 0 || i.lightpos.z < 0 || i.lightpos.z > 1)
                    return col;
                //在ndc空间下，深度即为z值
                float depth = i.lightpos.z;

                float shadow = PCF(depth,shadowUV,_filterSize);
               
                return col * shadow;
            }
            ENDCG
        }
    }
}
