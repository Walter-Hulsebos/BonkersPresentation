using UnityEngine;
using UnityEngine.Rendering;

[ImageEffectAllowedInSceneView]
[ExecuteInEditMode()]
public class NGSSEB_Bevel : MonoBehaviour
{
    public enum SAMPLING_QUALITY { LOW = 16, MED = 32, HIGH = 64, ULTRA = 128 }
    [Header("QUALITY PROPERTIES")]
    public SAMPLING_QUALITY m_SamplingQuality = SAMPLING_QUALITY.HIGH;
    //[Range(4, 64)]
    //public int m_bevelSamplers = 64;

    [Tooltip("Maximum distance where the effect will be visible. If set to 0 the effect will by applied to the visible frustum (up to camera far plane).")]
    public float m_bevelDistance = 30f;

    [Header("EDGE PROPERTIES")]
    [Range(0f, 1f)]
    public float m_bevelRadius = 0.25f;

    //[Range(0f, 1f)]
    //public float m_edgeThickness = 1f;

    [Range(0f, 1f)]
    public float m_edgeDistance = 0.9f;

    [Range(0f, 1f)]
    public float m_edgeOffset = 0.5f;

    //public Mesh m_Quad;

    /************************************************************************/

    private Shader m_BevelShader;
	private Material m_bevelMaterial;
	private CommandBuffer m_bevelBuffer;    
	private Camera m_Camera;
    private bool isSet = false;

	void OnDisable()
	{
        isSet = false;

        if (m_bevelBuffer != null && m_Camera)
            m_Camera.RemoveCommandBuffer (CameraEvent.BeforeLighting, m_bevelBuffer);

		m_bevelBuffer = null;
		DestroyImmediate (m_bevelMaterial);
	}
	
	void OnEnable()
	{
        //if (m_Quad == null) { enabled = false; Debug.LogWarning("Please provide the default Quad Mesh to this component and re-enable it again.", this); return; }

        if (m_Camera == null)
            m_Camera = GetComponent<Camera>();

        if (m_bevelMaterial == null)
		{
            //m_bevelMaterial = new Material(m_BevelShader);
            m_bevelMaterial = new Material(Shader.Find("Hidden/NGSSEB_Bevel"));
			m_bevelMaterial.hideFlags = HideFlags.HideAndDontSave;
		}

		if (m_bevelBuffer == null)
		{
			m_bevelBuffer = new CommandBuffer();
			m_bevelBuffer.name = "Bevel Command Buffer";
            /*
            var maskID = Shader.PropertyToID("_EdgeMask");//edge mask pass W.I.P for next update
            m_bevelBuffer.GetTemporaryRT(maskID, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.R8);
            m_bevelBuffer.Blit(BuiltinRenderTextureType.None, maskID, m_bevelMaterial, 0);//create the edge mask
            m_bevelBuffer.SetGlobalTexture("NGSSEB_EdgeMask", maskID);
            */
            var normalsID = Shader.PropertyToID("_NormalsCopy");
            m_bevelBuffer.GetTemporaryRT(normalsID, -1, -1, 0, FilterMode.Bilinear, RenderTextureFormat.ARGB2101010);
            m_bevelBuffer.Blit(BuiltinRenderTextureType.GBuffer2, normalsID);//, m_bevelMaterial, 0);//copy normals

            m_bevelBuffer.SetRenderTarget(BuiltinRenderTextureType.GBuffer2, BuiltinRenderTextureType.CameraTarget);
            m_bevelBuffer.Blit(normalsID, BuiltinRenderTextureType.CurrentActive, m_bevelMaterial, 1);
            //m_bevelBuffer.DrawMesh(m_Quad, Matrix4x4.identity, m_bevelMaterial, 1);

            //m_bevelBuffer.ReleaseTemporaryRT(maskID);
            m_bevelBuffer.ReleaseTemporaryRT(normalsID);

            m_Camera.AddCommandBuffer (CameraEvent.BeforeLighting, m_bevelBuffer);
		}

        isSet = true;
    }

    void OnPreRender()
    {
        if (isSet == false)
            return;

        m_bevelDistance = Mathf.Clamp(m_bevelDistance, 0f, m_Camera.farClipPlane);
        m_bevelMaterial.SetFloat("m_bevel_distance", m_bevelDistance == 0f ? m_Camera.farClipPlane : m_bevelDistance);
        m_bevelMaterial.SetFloat("m_bevel_radius", m_bevelRadius * 0.05f);
        m_bevelMaterial.SetFloat("m_edge_distance", (1f - m_edgeDistance) * 100f);
        m_bevelMaterial.SetFloat("m_edge_offset", m_edgeOffset * 10f);
        //m_bevelMaterial.SetFloat("m_edge_thickness", m_edgeThickness);
        //m_bevelMaterial.SetInt("m_bevel_samplers", m_bevelSamplers);
        m_bevelMaterial.DisableKeyword("POISSON_32"); m_bevelMaterial.DisableKeyword("POISSON_64"); m_bevelMaterial.DisableKeyword("POISSON_128");
        m_bevelMaterial.EnableKeyword(m_SamplingQuality == SAMPLING_QUALITY.ULTRA ? "POISSON_128" : m_SamplingQuality == SAMPLING_QUALITY.HIGH ? "POISSON_64" : m_SamplingQuality == SAMPLING_QUALITY.MED ? "POISSON_32" : "POISSON_16");
    }
}
