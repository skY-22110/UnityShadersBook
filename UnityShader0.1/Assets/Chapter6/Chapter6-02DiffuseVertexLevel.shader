﻿Shader "Unity Shaders Book/Chapter 6/Diffuse"{
	Properties{
		_Diffuse("Diffuse",COLOR)=(1,1,1,1)
	}
	SubShader{
		Pass{
			Tags {"LightMode"= "ForwardBase"}
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				fixed4 _Diffuse;
				struct appdata{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};
				struct v2f{
					float4 pos : SV_POSITION;
					float3 color : COLOR;
				};
				
				v2f vert(appdata v){
					v2f o;
					o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
					fixed3 worldNormal = normalize(mul(v.normal,(float3x3)_World2Object));
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));
					o.color = ambient + diffuse;
					return o;
				}
				
				fixed4 frag(v2f i):SV_Target{
					return fixed4(i.color,1.0);
				}
			ENDCG
		}
	}
	FallBack "Diffuse"
}