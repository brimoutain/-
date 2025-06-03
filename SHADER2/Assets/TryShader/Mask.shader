Shader "Unlit/Mask"
{
    Properties
    {
        _ID("Mask ID", Int) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry+1"}
        ColorMask 0
        ZWrite Off
        Stencil{
				Ref[_ID]
				Comp always	//Ĭ��keep
				Pass replace //Ĭ��keep
               	//Fail keep
                //ZFail keep
		}
        

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return half4(1,1,1,1);
            }
            ENDCG
        }
    }
}
