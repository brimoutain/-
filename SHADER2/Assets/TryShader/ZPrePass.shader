Shader "Unlit/ZPrePass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5  // 添加缺失的Cutoff属性
    }
    SubShader
    {
        // Pass 1: 深度预计算
        Pass
        {
            Tags {
                "Queue" = "AlphaTest"       // 保持AlphaTest队列
                "RenderType" = "TransparentCutout"
                "LightMode" = "ForwardBase"  // 明确指定光照模式
            }
            ZWrite On
            ZTest Less
            ColorMask 0  // 关闭颜色写入

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata  // 修正结构体定义
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                clip(color.a - _Cutoff);  // 使用正确定义的_Cutoff
                return 0;
            }
            ENDCG
        }

        // Pass 2: 不透明部分渲染
        Pass
        {
            Tags { 
                "Queue"="Geometry+10" 
                "LightMode" = "ForwardBase"
            }
            Cull Off
            ZWrite Off
            ZTest Equal  // 精确深度匹配

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_base v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }

        // Pass 3 & 4: 半透明双面渲染
        Pass  // 背面
        {
            Tags { 
                "Queue"="Transparent-50"  // 调整渲染顺序
                "RenderType"="Transparent"
            }
            Blend SrcAlpha OneMinusSrcAlpha  // 必须添加混合模式
            Cull Front
            ZWrite Off
            ZTest LEqual  // 改为LEqual

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_base v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.a *= 0.8;  // 示例：添加透明度控制
                return col;
            }
            ENDCG
        }

        Pass  // 正面（最后渲染）
        {
            Tags { 
                "Queue"="Transparent+50"  // 确保最后渲染
                "RenderType"="Transparent"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back
            ZWrite Off
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_base v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.a *= 0.5;  // 示例：正面更透明
                return col;
            }
            ENDCG
        }
    }
}