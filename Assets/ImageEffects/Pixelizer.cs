using UnityEngine;
using System.Collections;
using UnityStandardAssets.ImageEffects;


/// <summary>
/// Pixelizer.
/// Create pixeleted image effect using depth pass.
/// </summary>
namespace Custom.ImageEffects
{
	[ExecuteInEditMode]
	[RequireComponent (typeof(Camera))]
	[AddComponentMenu("Custom/Image Effects/Pixelizer")]

	public class Pixelizer : PostEffectsBase
	{
		//Enums and Var
		public enum PassType{
			DepthMap = 0,
			Pixelated = 1,
			Smoothed = 2
		}
		public PassType m_FilterType = PassType.DepthMap;

		public float m_XDiameter = 15f;
		public float m_YDiameter = 15f;
		public float m_ValueScale = 10f;
		public float m_Spread = 0.1f;

		public Shader m_PixelatedHSVShader;
		private Material m_PixelatedHSVMaterial;

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
			if(mat)
			{
				DestroyImmediate(mat);
				mat = null;
			}
		}

		public override bool CheckResources()
		{
			
			if (!SystemInfo.supportsImageEffects || !SystemInfo.SupportsRenderTextureFormat (RenderTextureFormat.Depth)) {
				m_Supported = false;
				enabled = false;
				return m_Supported;
			}
			
			CreateMaterials ();
			
			//TODO:Update pass count check
			if (!m_PixelatedHSVMaterial || m_PixelatedHSVMaterial.passCount == 0) {
				m_Supported = false;
				enabled = false;
				return m_Supported;
			}
			
			m_Supported = true;
			return m_Supported;
		}

		void OnDisable()
		{
			DestroyMaterial (m_PixelatedHSVMaterial);
		}

		void OnEnable()
		{
			GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
		}

		private void CreateMaterials()
		{
			if (!m_PixelatedHSVMaterial && m_PixelatedHSVShader.isSupported) {
				m_PixelatedHSVMaterial = CreateMaterial (m_PixelatedHSVShader);
			}
		}
	
		[ImageEffectOpaque]
		void OnRenderImage(RenderTexture source, RenderTexture destination)
		{
			if (!m_Supported || !m_PixelatedHSVShader.isSupported) {
				enabled = false;
				return;
			}
			CreateMaterials ();

			//Basic functions
			m_PixelatedHSVMaterial.SetVector ("_Params", new Vector3(
				-m_XDiameter,
				-m_YDiameter,
				m_ValueScale * 0.1f));

			m_PixelatedHSVMaterial.SetVector ("_Size", new Vector2 (
				source.width,
				source.height));

			m_PixelatedHSVMaterial.SetFloat ("_Spread", m_Spread);

			int pass = (int)m_FilterType;


			//Apply shader
			Graphics.Blit (source, destination, m_PixelatedHSVMaterial, pass);
		}
	}
}