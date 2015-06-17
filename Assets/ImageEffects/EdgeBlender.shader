Shader "Custom/EdgeBlender" {
	Properties {
		_MainTex("", 2D) = ""{}
		_EdgeTex("", 2D) = ""{}
	}
	SubShader {
		Pass{
			ZTest Always Cull Off ZWrite On
			Fog { Mode off }
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"
			
			uniform sampler2D _MainTex;
			uniform sampler2D _EdgeTex;
			uniform sampler2D_float _CameraDepthTexture;
			
			uniform float2 _Size;
			uniform float _Spread;
			uniform float _Threshold;
			uniform float4 _EdgeScale;
			uniform float _EdgeWeight;
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uve	: TEXCOORD1;
			};
			
			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = MultiplyUV (UNITY_MATRIX_TEXTURE0, v.texcoord);
				o.uve = v.texcoord.xy * _EdgeScale.zw + _EdgeScale.xy;
				return o;
			}
			
             struct fragOut
             {
                 half4 color : COLOR;
                 float depth : DEPTH;
             };
			
			fragOut frag( v2f i ) : SV_Target
			{
				float w = 1.0 / _Size.x;
				float h = 1.0 / _Size.y;
				half4 c = tex2D(_MainTex,i.uv);
			
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv);
				
				float2 coord = i.uv;
				float cd = 0;
				float nd = d;
				
				coord = float2(max(0,i.uv.x - _Spread), i.uv.y);
				nd = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,coord);
				cd = max(cd, abs(nd-d));
				
				coord = float2(min(1,i.uv.x + _Spread), i.uv.y);
				nd = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,coord);
				cd = max(cd, abs(nd-d));
				
				
				coord = float2(i.uv.x, max(0,i.uv.y - _Spread));
				nd = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,coord);
				cd = max(cd, abs(nd-d));
				
				
				coord = float2(i.uv.x, min(1,i.uv.y + _Spread));
				nd = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,coord);
				cd = max(cd, abs(nd-d));
				
				coord = float2(max(0,i.uv.x - _Spread), max(0,i.uv.y - _Spread));
				nd = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,coord);
				cd = max(cd, abs(nd-d));
				
				
				coord = float2(min(1,i.uv.x + _Spread), min(1,i.uv.y + _Spread));
				nd = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,coord);
				cd = max(cd, abs(nd-d));
				
				
				
				
				i.uve += float2(d,d);
				half4 e = tex2D(_EdgeTex,i.uve);
			
			//TODO: integrate depth into coloring
			//TODO: blending option
				if(cd > _Threshold)
					c.rgb = (((e.rgb*_EdgeWeight)+(c.rgb*(1.0-_EdgeWeight))) * e.a) + (c.rgb * (1.0 - e.a));
				
				
				fragOut o;
					o.color = c;
					o.depth = d;
				return o;
			}
			
			ENDCG
		}
	} 
	FallBack "off"
}
