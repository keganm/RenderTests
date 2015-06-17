Shader "Custom/SkyCarTires" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_OcclusionTex("Occlusion", 2D) = "grey" {}
		_BumpMap ("Bumpmap", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_RandomVector("Random Vectors", 2D) = "grey" {}
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
		sampler2D _RandomVector;
		sampler2D _OcclusionTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_OcclusionTex;
			float2 uv_BumpMap;
			float2 uv_RandomVector;
			
			float4 facingUV;
		};
		
		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input,o);
			o.facingUV = float4(mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal),1.0);
		}

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 nv = tex2D(_RandomVector, IN.uv_RandomVector);
			fixed4 oc = tex2D(_OcclusionTex, IN.uv_OcclusionTex);
		
			
			float vd = IN.facingUV.b;
			vd = pow(vd,20);
		
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color * vd;
			o.Albedo = c.rgb * oc.rgb + (nv.rgb * vd) + vd;
			
			o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic * (nv.r * 0.5 + 0.5);
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
