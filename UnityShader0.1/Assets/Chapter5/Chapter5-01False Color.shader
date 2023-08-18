Shader "Unity Shaders Book/Chapter 5/False Color" {
	SubShader{
	 	Pass{
	 		CGPROGRAM
	 		#pragma vertex vert
	 		#pragma fragment frag
	 		#include "UnityCG.cginc"
	 		
	 		struct v2f{
	 			float4 pos : SV_POSITION;
	 			fixed4 color : COLOR0;
	 		};
	 		
	 		v2f vert(appdata_full v){
	 			v2f o;
	 			o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
	 			//Show Normal
	 			o.color = fixed4(v.normal*0.5+fixed3(0.5,0.5,.5),1.0);
	 			//Show Main Tangent
	 			o.color = fixed4(v.tangent.xyz * 0.5 + fixed3(0.5,0.5,0.5),1.0);
	 			//Show Assistant Tangent
	 			fixed3 binormal = cross(v.normal,v.tangent.xyz)*v.tangent.w;
	 			o.color = fixed4(binormal*.5+fixed3(.5,.5,.5),1.0);
	 			
	 			//Show one texcoord
	 			o.color = fixed4(v.texcoord.xy,0.0,1.0);
	 			//Show two texcoord
	 			o.color = fixed4(v.texcoord1.xy,0.0,1.0);
	 			//Show one texcoord of single
	 			o.color = frac(v.texcoord);
	 			if(any(saturate(v.texcoord)-v.texcoord)){
	 				o.color.b = 0.5;
	 			}	
	 			o.color.a = 1.0;
				//Show two texcoord of single
	 			o.color = frac(v.texcoord1);
	 			if(any(saturate(v.texcoord1)-v.texcoord1)){
	 				o.color.b = 0.5;
	 			}	
	 			o.color.a = 1.0;
	 			
	 			//Show vertex Color
	 			o.color = v.color;
	 			return o;
	 		}
	 		
	 		fixed4 frag(v2f i):SV_Target{
	 			return i.color;
	 		}
	 		
	 		ENDCG
	 	}
	}
}
