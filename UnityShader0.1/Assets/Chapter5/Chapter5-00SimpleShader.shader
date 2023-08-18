Shader "Unity Shaders Book/Chapter 5/SimpleShader"{

	Properties{
		_Color("Color",Color)=(1.0,1.0,1.0,1.0)
	}
	SubShader{
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			float4 _Color;
			
			struct appdata{
				float4 pos : POSITION;
				float3 nor : NORMAL;
				float4 texcoord : TEXCOORD1;
			};
			
			struct v2f{
				float4 pos : SV_POSITION;
				fixed3 color : COLOR0;
			};
			
			v2f vert(appdata v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.pos);
				o.color = v.nor * .5 + fixed3(0.5,0.5,0.5);
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				fixed3 rel=i.color;
				rel*=_Color.rgb;
				return fixed4(rel,1.0);
			}
			ENDCG
		}
	}
}