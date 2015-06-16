Shader "Custom/PixelatedSurface" {

    Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_BumpMap ("Bumpmap", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_RandomVector("Random Vectors", 2D) = "gray" {}
    }
    SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
		
      struct Input {
          float2 uv_MainTex;
          float2 uv_BumpMap;
          float3 worldPos;
          float3 customColor;
      };
      
      void vert (inout appdata_full v, out Input o) {
          UNITY_INITIALIZE_OUTPUT(Input,o);
          o.customColor = v.vertex;
      }
      
      
      
		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _RandomVector;
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
      
      void surf (Input IN, inout SurfaceOutputStandard o) {
      
		fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
		fixed4 v = tex2D(_RandomVector, IN.uv_MainTex) * 0.5+0.5;
		
		float3 viewDir = mul ((float3x3)UNITY_MATRIX_MV, IN.customColor);
		float vd = viewDir.z;
		c.rgb *= vd * 0.05 + 0.95;
		clip (frac((IN.worldPos.y+IN.worldPos.x)*(v*(vd)*25)) - vd*.25);
		clip (frac((IN.worldPos.z+IN.worldPos.x)*(v*(vd)*25)) - vd*.25);
		
		o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
		o.Albedo = c.rgb + (vd * 2);


		// Metallic and smoothness come from slider variables
		o.Metallic = _Metallic;
		o.Smoothness = _Glossiness;
		o.Alpha = c.a;
      }
      ENDCG
    } 
    Fallback "Diffuse"
  }



//	Properties {
//		_MainTex ("Texture", 2D) = "white" {}
//		_XDiameter ("ScaleX", Range(0,1)) = 0.5
//		_YDiameter ("ScaleY", Range(0,1)) = 0.5
//	}
//	
//	SubShader {
//	Pass{
//		Tags { "RenderType"="Opaque" }
//		
//		CGPROGRAM
//		#pragma vertex vert
//		#pragma fragment frag
//		#pragma fragmentoption ARB_precision_hint_fastest
//		
//		#include "UnityCG.cginc"
//		
//		sampler2D _MainTex;
//		float _XDiameter;
//		float _YDiameter;
//		
//		struct v2f {
//			float4 pos : SV_POSITION;
//			float4  uv : TEXCOORD0;
//            fixed4 color : COLOR;
//		};
//		
//		
//		v2f vert(appdata_base v)
//		{
//			v2f o;
//			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
//			
//			//o.uv = float4 (v.texcoord.xy,0,0);
//            o.color = float4(v.normal * 0.5 + 0.5,0);
//            o.uv =  ComputeGrabScreenPos(o.pos+o.color);
//			
//			return o;
//		};
//		
//         struct fragOut
//         {
//             half4 color : COLOR;
//             float depth : DEPTH;
//         };
//		
//		
//		half4  frag( v2f i ) : SV_Target
//		{
//			float2 modifiedUV = i.uv.xy / i.uv.w;
//			modifiedUV /= float2(_XDiameter,_YDiameter);
//			modifiedUV = round(modifiedUV);
//			modifiedUV *= float2(_XDiameter,_YDiameter);
//			return tex2D(_MainTex, modifiedUV);
//		};
//		
//		ENDCG
//		
//    }
//  } 
//}
