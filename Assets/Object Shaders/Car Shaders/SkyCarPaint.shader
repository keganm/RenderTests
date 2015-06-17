Shader "Custom/SkyCarPaint" {
//TODO:Anisotropic approach for lighting?
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_OcclusionTex("Occlusion", 2D) = "grey" {}
		_Occlusion ("Occlusion Weight", Range(0,1)) = 0.5
		_BumpMap ("Normals", 2D) = "bump" {}
		_BumpWeight ("Normals Weight", Range(0,1)) = 0.5
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_AddHighlight("Extra Highlight", 2D) = "grey" {}
		_Sparkle("Sparkle", 2D) = "grey" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _AddHighlight;
		sampler2D _OcclusionTex;
		sampler2D _Sparkle;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float2 uv_Occlusion;
			float2 uv_Sparkle;
			
			float4 facingUV;
		};
		
		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input,o);
			o.facingUV = float4(mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal),1.0);
		}

		half _Glossiness;
		half _Metallic;
		half _Occlusion;
		half _BumpWeight;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
		
		
			fixed4 nv = tex2D(_AddHighlight, IN.facingUV.xy*.5);
			fixed4 oc = tex2D(_OcclusionTex, IN.uv_BumpMap);
			fixed4 spl = tex2D(_Sparkle, IN.facingUV.xy*.1);
			fixed4 spc = tex2D(_Sparkle, IN.uv_Sparkle);
			
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			
			float vd = IN.facingUV.b;
			vd = pow(vd,20);
			spl = pow(spl,4)*2;
			spc = pow(spc,3)*4;
			
			nv *= vd;
			
			c += (spl * vd) * 50;
			c += (spc * pow(vd,2)) * 50;
			c += nv;
			c *= oc * _Occlusion + (1. - _Occlusion);
			
			o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap))* _BumpWeight;
			o.Albedo = c.rgb;
			
			
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic * spl.r;
			o.Smoothness = _Glossiness * nv.r;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
