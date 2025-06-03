Shader "Unlit/FogTry"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGINCLUDE
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                half2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                half2 uv_depth : TEXCOORD1;
                float4 interpolatedRay : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _FogStart;
            float _FogEnd;
            float _FogDistance;
            float4 _FogColor;
            sampler2D _CameraDepthTexture;
            float4x4 _FrustumCornersRay;
            sampler2D _NoiseMap;
            float _NoiseAmount;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.uv_depth = v.texcoord;

                int index = 0;
                if(v.texcoord.x < 0.5 && v.texcoord.y < 0.5){
                    index = 0;
                }else if(v.texcoord.x > 0.5 && v.texcoord.y < 0.5){
                    index = 1;
                }else if(v.texcoord.x > 0.5 && v.texcoord.y > 0.5){
                    index = 2;
                }else
                    index = 3;

                o.interpolatedRay = _FrustumCornersRay[index];

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = float2(i.uv.x + _Time.x,i.uv.y);
                fixed noise = tex2D(_NoiseMap,uv);
                fixed amount = saturate(noise - _NoiseAmount);

                float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
                float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;

                float fogDensity = (_FogEnd - worldPos.y)/(_FogEnd - _FogStart);
                fogDensity = saturate(fogDensity * _FogDistance);
                fixed4 finalColor = tex2D(_MainTex,i.uv);
                fogDensity *=amount;
                finalColor.rgb = lerp(finalColor,_FogColor,fogDensity);

                return finalColor;
            }
            ENDCG
        }

        Pass
        {
            ZTest Always Cull Off ZWrite Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            ENDCG

        }
    }
    FallBack Off
}
