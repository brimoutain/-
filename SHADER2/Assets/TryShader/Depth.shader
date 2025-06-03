Shader "Unlit/Depth"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 depth : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.depth = o.pos.zw;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float depth = i.depth.x/i.depth.y;

                #if defined(SHADER_API_GLES) || defined(SHADER_API_GLES3)
                    depth = depth*0.5 + 0.5;
                #elif defined(UNITY_REVERSED_Z)
                    depth = 1 - depth;
                #endif
                return EncodeFloatRGBA(depth);
                //return fixed4(depth,depth,depth,1);

            }
            ENDCG
        }
    }
}
