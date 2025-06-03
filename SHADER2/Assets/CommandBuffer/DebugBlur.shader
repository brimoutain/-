Shader "Unlit/DebugBlur"
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
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _BlurTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // ������3�в��ԣ��ֱ�򿪿���Ч����

                // 1. �̶���ɫ���������Ա�
                // return fixed4(1,0,0,1);

                // 2. ������������ʾ
                // return tex2D(_MainTex, i.uv);

                // 3. ����ģ��������ʾ
                return tex2D(_BlurTex, i.uv);
            }
            ENDCG
        }
    }

}
