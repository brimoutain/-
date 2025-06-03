Shader "Unlit/Bloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //模糊后处理和原图叠加
        _Bloom("Bloom",2D) = "black" {}
        _LuminateThreshold("LuminateThreshold",Float) = .5
        _BlurSize("BlurSize",Float) = 1
    }
    SubShader
    {
        ZTest Always Cull Off ZWrite Off
        CGINCLUDE
        #include "UnityCG.cginc"
        sampler2D _MainTex;
        float4 _MainTex_TexelSize;
        sampler2D _Bloom;
        float _LuminateThreshold;
        float _BlurSize;

        struct v2fExtractBright{
            float4 pos : SV_POSITION;  
            half2 uv : TEXCOORD0; 
        };
        
        v2fExtractBright vertExtractBright(appdata_img v){
            v2fExtractBright o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;

            return o;
        }

        fixed luminate(fixed4 color){
            return color.r*0.2125 + color.g * 0.7154 + color.b * 0.0721;
        }

        fixed4 fragExtractBright(v2fExtractBright i) : SV_TARGET{
            fixed4 c = tex2D(_MainTex,i.uv);
            fixed4 val = clamp(luminate(c) - _LuminateThreshold,0.0,1.0);
            return val*c;
        }

        struct v2fBlur{
            float4 pos : SV_POSITION;
            half2 uv[5] : TEXCOORD0;
        };

        v2fBlur vertBlurVertical(appdata_img v){
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

        v2fBlur vertBlurHorizontal(appdata_img v){
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

        //高斯模糊用frag
        fixed4 fragBlur(v2fBlur i) : SV_TARGET{
            float weight[3] = {0.4026,0.2442,0.0545};
            fixed3 sum = tex2D(_MainTex,i.uv[0]).rgb * weight[0];

            for(int it = 1;it<3;it++){
                sum += tex2D(_MainTex,i.uv[it*2-1]).rgb * weight[it];
                sum += tex2D(_MainTex,i.uv[it*2]).rgb * weight[it];
            }

            return fixed4(sum,1.0);
        }

        struct v2fBloom{
            float4 pos : SV_POSITION;
            half4 uv : TEXCOORD0;
        };

        v2fBloom vertBloom(appdata_img v){
            v2fBloom o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.texcoord;
            o.uv.zw = v.texcoord;

            #if UNITY_UV_START_AT_TOP
            if(_MainTex_TexelSize.y < 0.0)
                o.uv.w = 1- o.uv.w;
            #endif

            return o;
        }

        fixed4 fragBloom(v2fBloom i) : SV_TARGET{
            return tex2D(_MainTex,i.uv.xy) + tex2D(_Bloom,i.uv.zw);
        }

        ENDCG

        //提取较亮区域
        Pass
        {       
            CGPROGRAM
            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright
            ENDCG
        }
        //竖直方向高斯模糊
        Pass
        {
            CGPROGRAM
            #pragma vertex vertBlurVertical
            #pragma fragment fragBlur
            ENDCG
        }
        //水平方向高斯模糊
        Pass
        {
            CGPROGRAM
            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBlur
            ENDCG
        }
        //模糊结果与原图混合
        Pass
        {
            CGPROGRAM
            #pragma vertex vertBloom
            #pragma fragment fragBloom
            ENDCG
        }
    }
}
