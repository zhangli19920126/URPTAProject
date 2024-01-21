using System;
using System.Collections.Generic;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class OutlineRendererFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class OutlineSettings : BaseRendererFeatureSettings
    {
        public FilterSettings filterSettings = new FilterSettings();
    }
    
    public OutlineSettings settings = new OutlineSettings();
    
    private OutlineRenderPass m_outlinePass;
   
    public override void Create()
    {
        m_outlinePass = new OutlineRenderPass(settings);
    }


    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_outlinePass);
    }
}

public  class OutlineRenderPass : ScriptableRenderPass
{
    private ProfilingSampler _profilingSampler = new ProfilingSampler("Outline");
    private FilteringSettings _filteringSettings;
    private List<ShaderTagId> _shaderTagIds = new List<ShaderTagId>();
    public OutlineRenderPass(OutlineRendererFeature.OutlineSettings settings)
    {
        renderPassEvent = RenderPassEvent.BeforeRenderingTransparents;
        _filteringSettings = new FilteringSettings(RenderQueueRange.opaque, settings.filterSettings.layerMask,
            (uint)(1 << (int)settings.filterSettings.renderingLayerMask));
        _shaderTagIds.Add(new ShaderTagId("Outline"));
    }
    
    
    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        var cmd = CommandBufferPool.Get();
        
        using (new ProfilingScope(cmd, _profilingSampler))
        {
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            var drawSetting = CreateDrawingSettings(_shaderTagIds, ref renderingData, SortingCriteria.CommonOpaque);
            context.DrawRenderers(renderingData.cullResults, ref drawSetting, ref _filteringSettings);
        }
       
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }
    
}



