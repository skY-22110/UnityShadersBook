Shader "Unlit/Chapter7-10NormalMapTangentSpace"
{
	Properties
	{
		_Color("Color",Color)=(1,1,1,1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map",2D) = "bump" {}
		_BumpScale ("Bump Scale",float) = 1.0
		_Specular ("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8.0,256)) = 20
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

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal :NORMAL;
				float4 tangent :TANGENT;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				float3 lightDir : TEXCOORD2;
			};

			sampler2D _MainTex;
			sampler2D _BumpMap;
			float4 _MainTex_ST;
			float4 _BumpMap_ST;
			float4 _Color;
			float _BumpScale;
			float4 _Specular;
			float _Gloss;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

				// float3 binormal = cross(normalize(v.normal),normal(v.tangent.xyz))*v.tangent.w;
				// float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
				// 等价与 TANGENT_SPACE_ROTATION;
				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				float4 packedNormal = tex2D(_BumpMap,i.uv.zw);
				float3 tangentNormal ;
				// 如果法线纹理没有设置成“NormalMap”
					//	tangentNormal.xy = (packedNormal.xy * 2-1) * _BumpScale;
					//	tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
				// 如果法线纹理设置成“NormalMap” ，并且使用内置的方法 UnpackNormal(packedNormal);
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
				float3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal,tangentLightDir));
				fixed3 halfDir = normalize(tangentViewDir+tangentLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal,halfDir)),_Gloss);
				fixed3 color = ambient + diffuse + specular;
				return fixed4(color,1.0);
			}
			ENDCG
		}
	}
}
