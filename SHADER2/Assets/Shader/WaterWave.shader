// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/WaterWave"
{
    Properties
    {
        _Color ("Main Color", Color) = (0, 0.15, 0.115, 1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_WaveMap ("Wave Map", 2D) = "bump" {} 
		_Cubemap ("Environment Cubemap", Cube) = "_Skybox" {}
		_WaveXSpeed ("Wave Horizontal Speed", Range(-0.1, 0.1)) = 0.01
		_WaveYSpeed ("Wave Vertical Speed", Range(-0.1, 0.1)) = 0.01
		_Distortion ("Distortion", Range(0, 100)) = 1.00
    }
    SubShader
    {
       Tags { "RenderType"="Opaque" "Queue"="Transparent"}

       GrabPass {"_RefractionTex"}

       Pass{
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #include "UnityCG.cginc"
		    #include "Lighting.cginc"
			
			#pragma multi_compile_fwdbase
			
			#pragma vertex vert
			#pragma fragment frag
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _WaveMap;
			float4 _WaveMap_ST;
			samplerCUBE _Cubemap;
			fixed _WaveXSpeed;
			fixed _WaveYSpeed;
			float _Distortion;	
			sampler2D _RefractionTex;
			float4 _RefractionTex_TexelSize;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT; 
				float4 texcoord : TEXCOORD0;
			};
			struct v2f{
				float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float4 uv : TEXCOORD1;
				float4 TtoW0 : TEXCOORD2;
				float4 TtoW1 : TEXCOORD3;
				float4 TtoW2 : TEXCOORD4;
				};
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.scrPos = ComputeGrabScreenPos(o.pos);

				o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord,_WaveMap);//准备储存WAveMap

				float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;

				o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

				return o;
				}
			fixed4 frag(v2f i) : SV_Target
			{
				float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				float2 speed = _Time.y * float2(_WaveXSpeed,_WaveYSpeed);

				//把法线贴图转化为法线
				fixed3 bump1 = UnpackNormal(tex2D(_WaveMap,i.uv.zw+speed)).rgb;
				fixed3 bump2 = UnpackNormal(tex2D(_WaveMap,i.uv.zw-speed)).rgb;
				fixed3 bump = normalize(bump1 + bump2);

				float2 offset = bump.xy * _Distortion * _RefractionTex_TexelSize.xy;//uv坐标扰动
				//物理意义：离相机越远的像素（scrPos.z 越大），相同扰动产生的视觉偏移量更大。
                //例如：水下物体离水面越远，折射导致的变形越明显。
				i.scrPos.xy = offset * i.scrPos.z + i.scrPos.xy;
				//齐次除法时屏幕坐标xy转化到0-1之间
				fixed3 refrCol = tex2D(_RefractionTex,i.scrPos.xy/i.scrPos.w).rgb;

				//把法线从切线空间转化到世界空间
				bump = normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));

				//法线不改变纹理颜色，这里让纹理一起偏移
				fixed4 texColor = tex2D(_MainTex,i.uv.xy + speed);
				fixed3 reflDir = reflect(-viewDir,bump);
				fixed3 reflCol = texCUBE(_Cubemap,reflDir).rgb * texColor.rgb * _Color.rgb;

				fixed fresnel = pow(1-saturate(dot(viewDir,bump)),4);
				fixed3 finalColor = lerp(refrCol,reflCol,fresnel);
				return fixed4(finalColor,1);
				}
           ENDCG
           }
    }
	FallBack Off
}
