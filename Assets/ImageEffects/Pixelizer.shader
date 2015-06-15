Shader "Custom/Pixelizer" {
	Properties {
		_MainTex("", 2D) = ""{}
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
			
			sampler2D _MainTex;
			float3 _Params; // x=diameter x, y=diameter Y, z=valueScale)
			float2 _Size;
			uniform sampler2D_float _CameraDepthTexture;
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				
				o.uv = MultiplyUV (UNITY_MATRIX_TEXTURE0, v.texcoord);
				
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
				
				float dx = _Params.x * w;
				float dy = _Params.y * h;
				float halfx = dx * 0.5f;
				float halfy = dy * 0.5f;
				float2 coord = float2((dx*floor(i.uv.x/dx))+halfx,(dy*floor(i.uv.y/dy))+halfy);
				
				half4 oc = tex2D(_MainTex, coord);
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,coord);
				d = (d * _Params.z);
			
				dx = (_Params.x * d) * w;
				dy = (_Params.y * d) * h;
				coord = float2((dx*floor(i.uv.x/dx))+halfx,(dy*floor(i.uv.y/dy))+halfy);
				
				half4 c = tex2D(_MainTex, coord);
				c.rgb = half3(d,d,d);
				
				fragOut o;
					o.color = c;
					o.depth = d;
				return o;
			}
			
			ENDCG
		}
		
		Pass{
		//Original Pass
		
			ZTest Always Cull Off ZWrite On
			Fog { Mode off }
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float3 _Params; // x=diameter x, y=diameter Y, z=valueScale)
			float2 _Size;
			uniform sampler2D_float _CameraDepthTexture;
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				
				o.uv = MultiplyUV (UNITY_MATRIX_TEXTURE0, v.texcoord);
				
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
				
				float dx = _Params.x * w;
				float dy = _Params.y * h;
				float halfx = dx * 0.5f;
				float halfy = dy * 0.5f;
				float2 coord = float2((dx*floor(i.uv.x/dx))+halfx,(dy*floor(i.uv.y/dy))+halfy);
				
				half4 oc = tex2D(_MainTex, coord);
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,coord);
				d = (d * _Params.z);
			
				dx = (_Params.x * d) * w;
				dy = (_Params.y * d) * h;
				coord = float2((dx*floor(i.uv.x/dx))+halfx,(dy*floor(i.uv.y/dy))+halfy);
				
				half4 c = tex2D(_MainTex, coord);
				//c.rgb = half3(d,d,d);
				
				fragOut o;
					o.color = c;
					o.depth = d;
				return o;
			}
			
			ENDCG
		}
		
		Pass{
			ZTest Always Cull Off ZWrite On
			Fog { Mode off }
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float3 _Params; // x=diameter x, y=diameter Y, z=valueScale)
			float2 _Size;
			uniform sampler2D_float _CameraDepthTexture;
			float _Spread;
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				
				o.uv = MultiplyUV (UNITY_MATRIX_TEXTURE0, v.texcoord);
				
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
				
				float dx = _Params.x * w;
				float dy = _Params.y * h;
				float halfx = dx * _Spread;
				float halfy = dy * _Spread;
				
				float d = 0.0f;
				
				float2 coord = float2((dx*floor(i.uv.x/dx))+halfx,(dy*floor(i.uv.y/dy))+halfy);
				d += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,coord);
				
				coord = float2((dx*floor(i.uv.x/dx))-halfx,(dy*floor(i.uv.y/dy))-halfy);
				d += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,coord);
				coord = float2((dx*floor(i.uv.x/dx))-halfx,(dy*floor(i.uv.y/dy))+halfy);
				d += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,coord);
				coord = float2((dx*floor(i.uv.x/dx))+halfx,(dy*floor(i.uv.y/dy))-halfy);
				d += SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,coord);
				
				d *= 0.25f;
				
				
				d = (d * _Params.z);
			
				dx = (_Params.x * d) * w;
				dy = (_Params.y * d) * h;
				coord = float2((dx*floor(i.uv.x/dx))+halfx,(dy*floor(i.uv.y/dy))+halfy);
				half4 c = tex2D(_MainTex, coord);
				
				coord = float2((dx*floor(i.uv.x/dx))-halfx,(dy*floor(i.uv.y/dy))-halfy);
				c += tex2D(_MainTex, coord);
				coord = float2((dx*floor(i.uv.x/dx))-halfx,(dy*floor(i.uv.y/dy))+halfy);
				c += tex2D(_MainTex, coord);
				coord = float2((dx*floor(i.uv.x/dx))+halfx,(dy*floor(i.uv.y/dy))-halfy);
				c += tex2D(_MainTex, coord);
				
				c *= 0.25f;
				
				
				
				//c.rgb = half3(d,d,d);
				
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
