Shader "Unlit/Bump"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Tint Color", Color) = (1,1,1,1) // 添加 _Color 属性

        [Toggle(_NORMALMAP)] _EnableBumpMap("Enable Normal/Bump Map", Float) = 0.0
        _NormalMap("NormalMap", 2D) = "bump" {}
        _NormalScale("NormalScale", Float) = 1

        [Toggle(_HEIGHTMAP)] _EnableHeightMap("Enable Height Map", Float) = 0.0
        [Toggle(_RELIEFMAP)] _EnableReliefMap("Enable Relief Map", Float) = 0.0
        _HeightMap("HeightMap", 2D) = "white" {} // 修正拼写错误
        _HeightScale("HeightScale", Range(0, 0.5)) = 0.005

        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3x3 tangentToWorld : TEXCOORD3; // 用于存储切线空间到世界空间的转换矩阵
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            float _NormalScale;

            sampler2D _HeightMap;
            float4 _HeightMap_ST;
            float _HeightScale;

            float4 _Specular;
            float _Gloss;

            float4 _Color; // 添加 _Color 变量

            v2f vert (a2v v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;

                // 计算切线空间到世界空间的转换矩阵
                float3 normalDir = normalize(UnityObjectToWorldNormal(v.normal));
                float3 tangentDir = normalize(UnityObjectToWorldDir(v.tangent.xyz));
                float3 bitangentDir = normalize(cross(normalDir, tangentDir) * v.tangent.w);
                o.tangentToWorld = float3x3(tangentDir, bitangentDir, normalDir);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                o.lightDir = mul(o.tangentToWorld, worldLightDir);
                o.viewDir = mul(o.tangentToWorld, worldViewDir);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);

                #if defined(_HEIGHTMAP) || defined(_RELIEFMAP)
                float height = 1 - tex2D(_HeightMap, i.uv.zw).r;
                float2 offuv = tangentViewDir.xy / (tangentViewDir.z + 0.001) * height * _HeightScale;
                i.uv.xy += offuv;
                i.uv.zw += offuv;
                #endif

                fixed4 packedNormal = tex2D(_NormalMap, i.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _NormalScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir, tangentNormal)), _Gloss);

                fixed3 color = ambient + diffuse + specular;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}