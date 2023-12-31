﻿Shader "Unity Shaders Book/Chapter 8/AlphaTest"
{
	Properties
	{
		_Color("Color",Color) =(1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
		_Cutoff("Alpha Cutoff",Range(0,1)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="TransparentCutout" "IgnoreProjector"="True" "Queue"="AlphaTest" }

		Pass
		{
			Tags{"LightMode"= "ForwardBase"}
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "Lighting.cginc"

				fixed4 _Color;
				sampler _MainTex;
				float4 _MainTex_ST;
				float _Cutoff;

				struct a2v{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float2 texcoord : TEXCOORD0;
				};
				struct v2f{
					float4 pos : SV_POSITION;
					float3 worldNormal : TEXCOORD0;
					float3 worldPos : TEXCOORD1;
					float2 uv : TEXCOORD2;
				};

				v2f vert(a2v v){
					v2f o;
					o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.worldPos = mul(_Object2World,v.vertex).xyz;
					o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
					return o;
				}

				fixed4 frag(v2f i):SV_Target{
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

					fixed4 texColor = tex2D(_MainTex,i.uv);
					clip(texColor.a - _Cutoff);
					fixed3 albedo = texColor.rgb * _Color.rgb;
					fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

					fixed3 color = diffuse + ambient;
					return fixed4(color,1.0);
				}
			ENDCG
		}
	}
	Fallback "Transparent/Cutout/VertexLit"
}
