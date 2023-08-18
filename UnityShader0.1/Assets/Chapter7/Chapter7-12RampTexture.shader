﻿Shader "Unity Shaders Book/Chapter 7/RampTexture"
{
	Properties
	{
		_Color ("Color",Color) = (1,1,1,1)
		_RampTex ("Texture", 2D) = "white" {}
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
	}
	SubShader
	{
		Pass {
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM 
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			float4 _Color ;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			float4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : texcoord0;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal :TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(_Object2World,v.vertex).xyz;
				o.uv = v.texcoord.xy * _RampTex_ST.xy + _RampTex_ST.zw;
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed halfLambert = 0.5 * dot(worldNormal,worldLightDir) + 0.5;
				fixed3 diffuseColor = tex2D(_RampTex,halfLambert.xx).rgb * _Color.rgb;
				fixed3 diffuse = _LightColor0.rgb * diffuseColor;

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(viewDir + worldLightDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);
				
				fixed3 color = ambient + diffuse + specular;

				return fixed4(color,1.0);
			}
			ENDCG
		}
	}
}
