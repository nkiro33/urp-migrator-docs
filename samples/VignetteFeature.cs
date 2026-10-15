using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

// URP replacement for the VignetteEffect OnRenderImage script: add it to the URP Renderer asset.
public class VignetteFeature : ScriptableRendererFeature
{
    public Material material;   // uses "Guide/Vignette (URP)"
    [Range(0, 1)] public float intensity = 0.5f;

    VignettePass m_Pass;

    public override void Create()
    {
        m_Pass = new VignettePass { renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing };
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (material == null) return;
        material.SetFloat("_Intensity", intensity);
        m_Pass.material = material;
        renderer.EnqueuePass(m_Pass);
    }

    class VignettePass : ScriptableRenderPass
    {
        public Material material;

        public VignettePass()
        {
            // The pass reads the camera color, so URP must render to a texture, not straight to the screen.
            requiresIntermediateTexture = true;
        }

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            var resources = frameData.Get<UniversalResourceData>();
            if (resources.isActiveTargetBackBuffer) return;

            // source -> material -> new texture, which then becomes the camera color for later passes.
            TextureHandle source = resources.activeColorTexture;
            TextureDesc desc = renderGraph.GetTextureDesc(source);
            desc.name = "Vignette";
            desc.clearBuffer = false;
            TextureHandle destination = renderGraph.CreateTexture(desc);

            renderGraph.AddBlitPass(new RenderGraphUtils.BlitMaterialParameters(source, destination, material, 0), "Vignette");
            resources.cameraColor = destination;
        }
    }
}
