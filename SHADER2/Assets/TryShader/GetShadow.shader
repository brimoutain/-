Shader "Unlit/GetShadow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 wpos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ShadowMap;
            float4 _ShadowMap_ST;
            float4x4 _ProjectionMV;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.wpos = mul(UNITY_MATRIX_M,v.vertex);
                o.wpos.w = 1;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float4 inlightPos = mul(_ProjectionMV,i.wpos);
                inlightPos.xyz /= inlightPos.w;//变到ndc空间
                float2 shadowUV = inlightPos.xy * 0.5 + 0.5;

                if (inlightPos.x < 0 || inlightPos.x > 1 || inlightPos.y < 0 || inlightPos.y > 1)
                {
                    return col; // 视为没阴影
                }


                float shadow = 0; //0为在阴影内，1为不在
                fixed sampleDepth = tex2D(_ShadowMap,shadowUV).r;

                float currentDepth = inlightPos.z;
                float bias = 0.005;
                shadow = (currentDepth - bias) > sampleDepth ? 0.3 : 1.0; // 0.3 = 柔化阴影
                //shadow = currentDepth > sampleDepth ? 0 : 1;
                col *= shadow;
                return col;
            }
            ENDCG
        }
    }
}
