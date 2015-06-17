Shader "Custom/EdgeBlender" {
//TODO:Needs 'SOMETHING' else
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_OcclusionTex("Occlusion", 2D) = "grey" {}
		_NormalMap ("Normals", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_EdgeTex ("EdgeTexture", 2D) = "white"{}
		
		
		_EdgeWeight ("EdgeWeight", Range(0,1)) = 0.0
		_EdgeMulti ("_EdgeMulti", Int) = 10000
		_EdgeSharp ("_EdgeSharp", Int) = 10
		_EdgeGlow ("_EdgeGlow(RGB)", Vector) = (1,1,1)
	}
	SubShader {
        Tags{  
            "RenderType" = "Tranparent" "Queue"="Geometry"
            }
		LOD 200
		ZWrite on
		
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert alpha:auto

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _OcclusionTex;
		sampler2D _NormalMap;
		sampler2D _EdgeTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_OcclusionTex;
			float2 uv_NormalMap;
			float2 uv_EdgeTex;
			
			float4 facingRatio;
			float3 viewDir;
		};
		
		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input,o);
			o.facingRatio = float4(mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal),1.0);
		}

		half _Glossiness;
		half _Metallic;
		half _EdgeWeight;
		half _EdgeMulti;
		half _EdgeSharp;
		half3 _EdgeGlow;
		
		
		
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed4 oc = tex2D (_OcclusionTex, IN.uv_OcclusionTex);
			fixed4 e = tex2D (_EdgeTex, IN.uv_EdgeTex);
			
			half f = max(pow(IN.viewDir.b,_EdgeSharp)*_EdgeMulti,_EdgeWeight);
			f = f < _EdgeWeight ? 0:f;
			f = min(1,e.a + f);
			//f *= c.a;
			
			clip(f < _EdgeWeight ? -1:1);
			
			c.rgb *= oc.rgb;
			//c.rgb = IN.viewDir;
			//c.rgb = fixed3(f,f,f);
			if(f > _EdgeWeight && f < _EdgeWeight + 0.91)
				o.Albedo = _EdgeGlow;
				else
				o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Normal = UnpackNormal (tex2D (_NormalMap, IN.uv_NormalMap))*f;
			o.Metallic = _Metallic*pow(f,2);
			o.Smoothness = _Glossiness*pow(f,2);
			o.Alpha = pow(f,2);
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
