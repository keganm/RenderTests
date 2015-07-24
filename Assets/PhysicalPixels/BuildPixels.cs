
/// <summary>
/// Build pixels.
/// Utilize Compute Shader for analyzing rendered scene
/// Todo: 
/// </summary>
using UnityEngine;
using System.Collections;
using UnityStandardAssets.ImageEffects;

namespace Custom.ImageEffects
{
	//[ExecuteInEditMode]
	[RequireComponent (typeof(Camera))]
	[AddComponentMenu("Custom/Image Effects/BuildPixels")]
	public class BuildPixels : PostEffectsBase
	{
		////////////////////
		////////////////////

		//Structures to be mirrored in compute shader
		struct VecMatPair
		{
			public Vector3 point;
			public Matrix4x4 matrix;
		}

		struct PixelBlock
		{
			public Vector2 uv;
			public Vector3 pos;
			public Vector4 col;
		}
		
		////////////////////
		////////////////////
		
		public ComputeShader analyzeShader;
		
		int getPixelBlocksHandle = -1;
		int multiplyHandle = -1;
		int getDepthHandle = -1;
		
		public Shader m_GetDepthShader;
		public Material m_GetDepthMaterial;

		public Material m_TestBlockMaterial;
		
		private bool m_Supported;

		int pixelBlockCount = 500;
		PixelBlock[] blocks;
		GameObject[] pixelObjects = null;
		public Vector3[] pos;



		void OnDisable ()
		{
			ReleasePixelBlocks ();

			DestroyMaterial (m_GetDepthMaterial);
		}
	
		void OnEnable ()
		{
			if (pixelObjects != null) {
				for (int i = 0; i < pixelObjects.Length; ++i) {
					DestroyImmediate (pixelObjects [i]);
				}
			}

			GetComponent<Camera> ().depthTextureMode |= DepthTextureMode.DepthNormals;
			
			ReleasePixelBlocks ();
			GetHandles ();
		}

		private void GetHandles()
		{
			getDepthHandle = analyzeShader.FindKernel ("GetDepth");
			getPixelBlocksHandle = analyzeShader.FindKernel ("GetPixelBlocks");
			multiplyHandle = analyzeShader.FindKernel ("Multiply");
		}
	
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
			
			m_GetDepthMaterial = CreateMaterial (m_GetDepthShader);
			
			//TODO:Update pass count check
			if (!m_GetDepthMaterial || m_GetDepthMaterial.passCount == 0) {
				m_Supported = false;
				enabled = false;
				return m_Supported;
			}
			
			m_Supported = true;
			return m_Supported;
		}

		void OnPreCull()
		{
			//TODO:Switch Rendering approach so everything can be kept on the GPU
			if (blocks == null)
				return;

			if(pixelObjects == null)
				pixelObjects = new GameObject [blocks.Length];
			else if (pixelObjects.Length != blocks.Length) {
				ReleasePixelBlocks ();
				pixelObjects = new GameObject [blocks.Length];
			}

			for(int i = 0; i < pixelObjects.Length; i++)
			{
				if(pixelObjects[i] == null){
					pixelObjects[i] = GameObject.CreatePrimitive(PrimitiveType.Cube);
					//Assigning a material that doesn't write to depth
					pixelObjects[i].GetComponent<Renderer>().material = m_TestBlockMaterial;
				}
				pixelObjects[i].transform.position = blocks[i].pos;
				//TODO:Fix the custom color leak
				pixelObjects[i].GetComponent<Renderer>().material.color = blocks[i].col;
			}
		}

		void OnPostRender()
		{
		}


		[ImageEffectOpaque]
		void OnRenderImage (RenderTexture source, RenderTexture destination)
		{
			//RunGetDepth (source, destination);
			
			RunGetPixelBlocks (source, destination);
		}

		///////////////////////////////////
		//// Pixel Blocks Methods
		///////////////////////////////////
		/// <summary>
		/// Inits the blocks.
		/// </summary>

		void InitBlocks()
		{
		//	if (blocks == null) 
		//		return;

			if (blocks != null)
				return;
			blocks = new PixelBlock[pixelBlockCount];

			for (int i = 0; i < blocks.Length; ++i) {
				blocks[i].col = Vector4.zero;
				blocks[i].pos = Vector3.zero;
				blocks[i].uv = Random.insideUnitCircle;
			}
		}
		/// <summary>
		/// Runs the get pixel blocks.
		/// </summary>
		/// <param name="source">Source.</param>
		/// <param name="destination">Destination.</param>
		void RunGetPixelBlocks(RenderTexture source, RenderTexture destination)
		{
			if (getPixelBlocksHandle == -1)
				return;
			
			RenderTexture depthTex = TransferDepthBuffer (source);
			if (depthTex == null) {
				return;
			}

			
			
			InitBlocks ();
			
			ComputeBuffer blocksBuffer = new ComputeBuffer (blocks.Length, sizeof(float) * 9);
			blocksBuffer.SetData (blocks);
			
			analyzeShader.SetFloat ("w", source.width);
			analyzeShader.SetFloat ("h", source.height);
			analyzeShader.SetFloat ("nearClipPlane", Camera.main.nearClipPlane);
			analyzeShader.SetFloat ("farClipPlane", Camera.main.farClipPlane);

			ComputeBuffer localToWorldBuffer = new ComputeBuffer (1, 64);
			Matrix4x4[] camMatrix = {Camera.main.transform.localToWorldMatrix};
			localToWorldBuffer.SetData (camMatrix);
			analyzeShader.SetBuffer (getPixelBlocksHandle, "localToWorldMatrix", localToWorldBuffer);

			
			analyzeShader.SetTexture (getPixelBlocksHandle, "Input", source);
			analyzeShader.SetTexture (getPixelBlocksHandle, "DepthBuffer", depthTex);
			analyzeShader.SetBuffer (getPixelBlocksHandle, "PixelBlocks", blocksBuffer);

			analyzeShader.Dispatch (getPixelBlocksHandle, blocks.Length, 1, 1);
			
			blocksBuffer.GetData (blocks);
			Graphics.Blit(source,destination);

			
			/// Release everything
			blocksBuffer.Release ();
			depthTex.Release ();
			localToWorldBuffer.Release ();
		}

		void ApplyPixelBlocks()
		{	
			for (int i = 0; i < blocks.Length; i++)
				pos [i] = blocks [i].pos;
		}

		void ReleasePixelBlocks()
		{
			if (pixelObjects == null)
				return;

			foreach (GameObject pix in pixelObjects)
				if(pix != null)
					DestroyImmediate (pix);

		}

		
		///////////////////////////////////
		//// Pixel Blocks Methods
		///////////////////////////////////
		/// <summary>
		/// Runs the get depth.
		/// </summary>
		/// <param name="source">Source.</param>
		/// <param name="destination">Destination.</param>
		void RunGetDepth (RenderTexture source, RenderTexture destination)
		{
			if (getDepthHandle == -1)
				return;

			RenderTexture depthTex = TransferDepthBuffer (source);
			if (depthTex == null) {
				Graphics.Blit(source,destination);
				return;
			}

			RenderTexture outTex = new RenderTexture (source.width, source.height, source.depth);
			outTex.enableRandomWrite = true;
			outTex.Create ();

			analyzeShader.SetTexture (getDepthHandle, "Result", outTex);
			analyzeShader.SetTexture (getDepthHandle, "DepthBuffer", depthTex);
			analyzeShader.SetTexture (getDepthHandle, "Input", source);
			analyzeShader.Dispatch (getDepthHandle, outTex.width / 8, outTex.height / 8, 1);

			Graphics.Blit (outTex, destination);


			/// Release everything
			outTex.Release ();
			depthTex.Release ();
		}
		
		///////////////////////////////////
		//// Utilities Methods
		///////////////////////////////////
		 
		RenderTexture TransferDepthBuffer(RenderTexture _source)
		{
			m_GetDepthMaterial = CreateMaterial (m_GetDepthShader);
			
			if (m_GetDepthMaterial == null)
				return null;

			RenderTexture depthTex = new RenderTexture (_source.width, _source.height, _source.depth);
			Graphics.Blit (_source, depthTex, m_GetDepthMaterial,0);

			return depthTex;
		}
	}
}
