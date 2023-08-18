Shader "Unity Shaders Book/Chapter 6/HalfLambert"
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
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
			fixed4 _Diffuse;
			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
			};
			
			v2f vert(a2v v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.worldNormal = mul(v.normal,(float3x3)_World2Object);
				return o;
			}
			fixed4 frag(v2f o):SV_Target{
				fixed3 worldNormal = normalize(o.worldNormal);
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (0.5 * dot(worldNormal,worldLight)+.5);
				fixed3 color = ambient + diffuse;
				return fixed4(color,1);
			}
			ENDCG
		}
	}
}
