using UnityEngine;
using System.Collections;
using UnityStandardAssets.ImageEffects;

namespace Custom.ImageEffects
{
	[ExecuteInEditMode]
	[RequireComponent (typeof(Camera))]
	[AddComponentMenu("Custom/Image Effects/EdgeBlender")]

	public class EdgeBlender : PostEffectsBase
	{
		public Texture m_EdgeTexture;
		public float m_EdgeScale;
		public float m_EdgeWeight = 0.5f;
		public float m_Spread = 0.1f;
		public float m_Threshold = 0.1f;
		public Shader m_EdgeBlenderShader;
		private Material m_EdgeBlenderMaterial;
		private bool m_Supported;
		
		//Basics
		private static Material CreateMaterial (Shader shader)
		{
			if (!shader)
				return null;
			
			Material m = new Material (shader);
			m.hideFlags = HideFlags.HideAndDontSave;
			
			return m;
		}
		
		private static void DestroyMaterial (Material mat)
		{
			if (mat) {
				DestroyImmediate (mat);
				mat = null;
			}
		}
		
		public override bool CheckResources ()
		{
			
			if (!SystemInfo.supportsImageEffects || !SystemInfo.SupportsRenderTextureFormat (RenderTextureFormat.Depth)) {
				m_Supported = false;
				enabled = false;
				return m_Supported;
			}
			
			CreateMaterials ();
			
			//TODO:Update pass count check
			if (!m_EdgeBlenderMaterial || m_EdgeBlenderMaterial.passCount == 0) {
				m_Supported = false;
				enabled = false;
				return m_Supported;
			}
			
			m_Supported = true;
			return m_Supported;
		}
		
		void OnDisable ()
		{
			DestroyMaterial (m_EdgeBlenderMaterial);
		}
		
		void OnEnable ()
		{
			GetComponent<Camera> ().depthTextureMode |= DepthTextureMode.DepthNormals;
		}

		private void CreateMaterials ()
		{
			if (!m_EdgeBlenderMaterial && m_EdgeBlenderShader.isSupported) {
				m_EdgeBlenderMaterial = CreateMaterial (m_EdgeBlenderShader);
			}
		}
		
		[ImageEffectOpaque]
		void OnRenderImage (RenderTexture source, RenderTexture destination)
		{
			if (!m_Supported || !m_EdgeBlenderShader.isSupported) {
				enabled = false;
				return;
			}
			CreateMaterials ();
			
			//Basic functions
			
			m_EdgeBlenderMaterial.SetTexture("_EdgeTex", m_EdgeTexture);
			m_EdgeBlenderMaterial.SetVector("_EdgeScale", new Vector4(
				(float)Screen.width / (float)m_EdgeTexture.width * m_EdgeScale,
				(float)Screen.height / (float)m_EdgeTexture.height * m_EdgeScale,
				(float)Screen.width / (float)m_EdgeTexture.width * m_EdgeScale,
				(float)Screen.height / (float)m_EdgeTexture.height * m_EdgeScale
				));

			m_EdgeBlenderMaterial.SetVector ("_Size", new Vector2 (
				source.width,
						source.height));
			m_EdgeBlenderMaterial.SetFloat ("_EdgeWeight", m_EdgeWeight);
			m_EdgeBlenderMaterial.SetFloat ("_Spread", m_Spread * 0.001f);
			m_EdgeBlenderMaterial.SetFloat ("_Threshold", m_Threshold * 0.001f);
			
			
			//Apply shader
			Graphics.Blit (source, destination, m_EdgeBlenderMaterial);
		}
	}
}
