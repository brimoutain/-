// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/AlphaTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff("Cutoff",Range(0.0,1.0)) = 0.0
    }
    SubShader
    {
        Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                float3 halfLanbert = normalize(worldViewDir + i.worldNormal);

                UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

                float4 color = tex2D(_MainTex,i.uv);
                clip(color.a - _Cutoff);
                float3 albedo = color.xyz;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo.xyz;
                float3 diffuse = _LightColor0.rgb * albedo.xyz * saturate(dot(worldLightDir,i.worldNormal));

                return fixed4(diffuse*atten + ambient ,1.0);
            }
            ENDCG
        }
    }
    FallBack "Transparent/Cutout/VertexLit"
}
