Shader "Unity Shaders Book/Chapter 7/MaskTexture"
{
	Properties
	{
		_MainTex ("Main Tex", 2D) = "white" {}
		_Color("Color",Color ) = (1,1,1,1)
		_BumpMap("Normal Tex",2D) = "bump" {}
		_BumpScale("BumpScale",float) = .8
		_SpecularMask("Specular Mask",2D) = "white" {}
		_SpecularScale("Specular Scale",float) = 1
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
	}
	SubShader
	{
		Pass
		{
			Tags {"LightMode"= "ForwardBase"}
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "Lighting.cginc"
				#include "UnityCG.cginc"

				fixed4 _Color ;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpMap;
				float4 _BumpMap_ST;
				float _BumpScale;
				sampler2D _SpecularMask;
				float4 _SpecularMask_ST;
				float _SpecularScale;
				fixed4 _Specular;
				float _Gloss;

				struct a2v{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 tangent : TANGENT;
					float4 texcoord : TEXCOORD0;
				};

				struct v2f{
					float4 pos : SV_POSITION;
					float3 LightDir : TEXCOORD0;
					float3 viewDir : TEXCOORD1;
					float2 uv : TEXCOORD2;
				};

				v2f vert(a2v v){
					v2f o;
					o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
					// 将 光线 和 视角方向 从模型空间转换到切线空间
					TANGENT_SPACE_ROTATION;
					o.LightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
					o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
					return o;
				}

				fixed4 frag(v2f i):SV_Target{
					fixed3 tangentLightDir = normalize(i.LightDir);
					fixed3 tangentViewDir = normalize(i.viewDir);
					fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap,i.uv));

					tangentNormal.xy *= _BumpScale;
					tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

					float3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;

					float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

					float3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal,tangentLightDir));

					float3 halfDir = normalize(tangentViewDir+tangentLightDir);
					fixed specularMask = tex2D(_SpecularMask,i.uv).r * _SpecularScale;
					fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal,halfDir)),_Gloss) * specularMask;

					fixed3 color = ambient + diffuse + specular;
					return fixed4(color,1.0);
				}

			ENDCG
		}
	}
	Fallback "Specular"
}
