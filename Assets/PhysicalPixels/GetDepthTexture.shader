Shader "Custom/GetDepthTexture" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "" {}
	}
	
	
Subshader {
	
 Pass {
	ZTest Always Cull Off ZWrite Off

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"
	
	struct v2f {
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
	};
		
	sampler2D _MainTex;
	sampler2D_float _CameraDepthTexture;
		
	v2f vert( appdata_img v ) 
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv =  v.texcoord.xy;
		return o;
	}
	
	//TODO: add scaling here or in compute shader
	half4 frag(v2f i) : SV_Target 
	{
		half4 c = tex2D(_MainTex, i.uv.xy);
		float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv.xy);
		d = Linear01Depth(d);
			 
		if(d>0.99999)
			return half4(c.rgb,1);
		else
			return half4(c.rgb,d); 
	}
      
      ENDCG
  }
}

Fallback off
	
} // shader
