Shader "Unlit/ZPrePass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5  // ���ȱʧ��Cutoff����
    }
    SubShader
    {
        // Pass 1: ���Ԥ����
        Pass
        {
            Tags {
                "Queue" = "AlphaTest"       // ����AlphaTest����
                "RenderType" = "TransparentCutout"
                "LightMode" = "ForwardBase"  // ��ȷָ������ģʽ
            }
            ZWrite On
            ZTest Less
            ColorMask 0  // �ر���ɫд��

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata  // �����ṹ�嶨��
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
                clip(color.a - _Cutoff);  // ʹ����ȷ�����_Cutoff
                return 0;
            }
            ENDCG
        }

        // Pass 2: ��͸��������Ⱦ
        Pass
        {
            Tags { 
                "Queue"="Geometry+10" 
                "LightMode" = "ForwardBase"
            }
            Cull Off
            ZWrite Off
            ZTest Equal  // ��ȷ���ƥ��

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

        // Pass 3 & 4: ��͸��˫����Ⱦ
        Pass  // ����
        {
            Tags { 
                "Queue"="Transparent-50"  // ������Ⱦ˳��
                "RenderType"="Transparent"
            }
            Blend SrcAlpha OneMinusSrcAlpha  // ������ӻ��ģʽ
            Cull Front
            ZWrite Off
            ZTest LEqual  // ��ΪLEqual

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
                col.a *= 0.8;  // ʾ�������͸���ȿ���
                return col;
            }
            ENDCG
        }

        Pass  // ���棨�����Ⱦ��
        {
            Tags { 
                "Queue"="Transparent+50"  // ȷ�������Ⱦ
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
                col.a *= 0.5;  // ʾ���������͸��
                return col;
            }
            ENDCG
        }
    }
}