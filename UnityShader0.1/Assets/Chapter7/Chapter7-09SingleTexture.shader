Shader "Unity Shaders Book/Chapter 7/SingleTexture"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
		_MainTex("MainTex",2D) = "white"{}
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
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

			struct a2v{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			struct v2f{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specular;
			float _Gloss;
			v2f vert(a2v v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(_Object2World,v.vertex).xyz;
				o.uv =v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw; 
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				// 环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				// 贴图采样
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
				// 世界法线
				fixed3 worldNormal = normalize(i.worldNormal);
				// 世界光方向
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				// 漫反射
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));
				// 视角方向
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				// 半方向
				fixed3 halfDir = normalize(viewDir + worldLightDir);
				// 高光反射
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);
				fixed3 color = ambient + diffuse + specular;
				return fixed4(color,1.0);
			}
			ENDCG
		}
	}
	FallBack "Specular"
}
