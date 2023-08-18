Shader "Unity Shaders Book/Chapter 6/DiffusePixelLevel"
{
	Properties
	{
		_Diffuse("Diffuse",Color)=(1,1,1,1)	
	}
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			
			struct appdata{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct v2f{
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
			};
			
			fixed4 _Diffuse;
			
			v2f vert(appdata v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
			//	fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				o.worldNormal = normalize(mul(v.normal,(float3x3)_World2Object));
			//	fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
			//	fixed3 diffuse = (_LightColor0.rgb * _Diffuse.rgb)* saturate(dot(worldNormal,worldLight));
			//	o.color =ambient+ diffuse;
				return o;
			}
			
			fixed4 frag(v2f v):SV_Target{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize(v.worldNormal);
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = (_LightColor0.rgb * _Diffuse.rgb) * saturate(dot(worldNormal,worldLight));
				fixed3 ref = ambient + diffuse;
				return fixed4(ref,1.0);
			}
			
			ENDCG
		}
	}
}
