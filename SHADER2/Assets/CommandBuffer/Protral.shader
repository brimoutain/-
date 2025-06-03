Shader "Unlit/BlurForCommand"
{
    Properties
    {
         _MainTex ("Texture", 2D) = "white" {}
         _BlurStrength("BlurStrength",Range(0,2)) = 0.5
         _NoiseMap("NoiseMap",2D) = "white" {}
         _NoiseStrength("NoiseStrength",Range(0,2)) = 0.5
    }
    SubShader
    {     
        Tags { 
            "Queue" = "Transparent" 
            "RenderType" = "Transparent" 
            "IgnoreProjector" = "True" 
        }
        Blend SrcAlpha OneMinusSrcAlpha // 标准透明混合
        ZWrite Off // 透明物体通常关闭深度写入
        // 开启深度写入但不渲染颜色（仅标记 Stencil）
        //ZWrite On
        //ColorMask 0

        Stencil {
            Ref 1          // Stencil 参考值
            Comp Always    // 始终通过测试
            Pass Replace   // 将 Ref 值写入 Stencil Buffer
        }

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
                //float4 blurUV : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BlurTex;
            float4 _BlurTex_ST;
            float _BlurStrength;
            sampler2D _NoiseMap;
            float4 _NoiseMap_ST;
            float _NoiseStrength;

            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv + tex2D(_NoiseMap,i.uv).xy;
                fixed4 col = tex2D(_MainTex,uv);        
                fixed4 blur = tex2D(_BlurTex,uv);

                fixed4 blured = lerp(col,blur,_BlurStrength);

                return tex2D(_BlurTex, i.uv);
            }
            ENDCG
        }
    }
}
