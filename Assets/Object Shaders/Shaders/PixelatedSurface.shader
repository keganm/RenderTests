Shader "Custom/PixelatedSurface" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_XDiameter ("ScaleX", Range(0,1)) = 0.5
		_YDiameter ("ScaleY", Range(0,1)) = 0.5
	}
	
	SubShader {
	Pass{
			ZTest Always Cull Off ZWrite On
		Tags { "RenderType"="Opaque" }
		
		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma fragmentoption ARB_precision_hint_fastest
		
		#include "UnityCG.cginc"
		
		sampler2D _MainTex;
		float _ScaleX;
		float _ScaleY;
		
		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
		};
		
		
		v2f vert(appdata_base v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			
			o.uv = MultiplyUV (UNITY_MATRIX_TEXTURE0, v.texcoord);
			
			return o;
		};
		
         struct fragOut
         {
             half4 color : COLOR;
             float depth : DEPTH;
         };
		
		
		fragOut frag( v2f i ) : SV_Target
		{
			float w = 1.0 / 512.;
			float h = 1.0 / 512.;
			
			float dx = _ScaleX * w;
			float dy = _ScaleY * h;
			float halfx = dx * 0.5f;
			float halfy = dy * 0.5f;
			float2 coord = float2((dx*floor(i.uv.x/dx))+halfx,(dy*floor(i.uv.y/dy))+halfy);
			
			half4 oc = tex2D(_MainTex, coord);
			float d = ((oc.r + oc.g + oc.b) * 0.3333) * oc.a;
			d = (d * 10.0);
		
			dx = (_ScaleX * d) * w;
			dy = (_ScaleY * d) * h;
			coord = float2((dx*floor(i.uv.x/dx))+halfx,(dy*floor(i.uv.y/dy))+halfy);
			
			half4 c = tex2D(_MainTex, coord);
			c.rgb = half3(d,d,d);
			
			fragOut o;
				o.color = c;
				o.depth = d;
			return o;
		};
		
		ENDCG
		
    }
  } 
}
