Shader "Unlit/Blur"
{
    Properties
    {
    }

    SubShader
    {
        CGINCLUDE
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        float _BlurSize;

        struct v2fBlur {
            float4 pos : SV_POSITION;
            half2 uv[5] : TEXCOORD0; // 扩展至9个采样点
        };

        v2fBlur BlurHorizontal(appdata_img v){
            v2fBlur o;
            o.pos = UnityObjectToClipPos(v.vertex);
            half2 uv = v.texcoord;

            o.uv[0] = uv;
            o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0,0) * _BlurSize;
            o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0,0) * _BlurSize;
            o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0,0) * _BlurSize;
            o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0,0) * _BlurSize;

            return o;
        }

        v2fBlur BlurVertical(appdata_img v){
            v2fBlur o;
            o.pos = UnityObjectToClipPos(v.vertex);
            half2 uv = v.texcoord;

            o.uv[0] = uv;
            o.uv[1] = uv + float2(0,_MainTex_TexelSize.y * 1.0) * _BlurSize;
            o.uv[2] = uv - float2(0,_MainTex_TexelSize.y * 1.0) * _BlurSize;
            o.uv[3] = uv + float2(0,_MainTex_TexelSize.y * 2.0) * _BlurSize;
            o.uv[4] = uv - float2(0,_MainTex_TexelSize.y * 2.0) * _BlurSize;

            return o;
        }

        //高斯模糊用frag
        fixed4 BlurFrag(v2fBlur i) : SV_TARGET{
            float weight[3] = {0.4026,0.2442,0.0545};
            fixed3 sum = tex2D(_MainTex,i.uv[0]).rgb * weight[0];

            for(int it = 1;it<3;it++){
                sum += tex2D(_MainTex,i.uv[it*2-1]).rgb * weight[it];
                sum += tex2D(_MainTex,i.uv[it*2]).rgb * weight[it];
            }

            //return fixed4(sum, 1.0);
            return tex2D(_MainTex, i.uv[0]);
        }
        ENDCG

        Pass{
            CGPROGRAM
            #pragma vertex BlurVertical
            #pragma fragment BlurFrag
            ENDCG
        }
        Pass{
            CGPROGRAM
            #pragma vertex BlurHorizontal
            #pragma fragment BlurFrag
            ENDCG
        }
    }
}