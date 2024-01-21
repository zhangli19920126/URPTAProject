
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[System.Serializable]
public class FilterSettings
{
    public LayerMask layerMask;
    public RenderingLayerMask renderingLayerMask;
    //public string[] shaderTagIds;

    public FilterSettings()
    {
        layerMask = -1;
        renderingLayerMask = RenderingLayerMask.LightLayerDefault;
    }

    public FilterSettings(int layerMask, RenderingLayerMask renderingLayerMask)
    {
        this.layerMask = layerMask;
        this.renderingLayerMask = renderingLayerMask;
    }
}

public class BaseRendererFeatureSettings
{
    public bool toggle = false;
}

public enum RenderingLayerMask
{
    LightLayerDefault = 0,
    LightLayer1 = 1,
    LightLayer2 = 2,
    LightLayer3 = 3,
    LightLayer4 = 4,
    LightLayer5 = 5,
    LightLayer6 = 6,
    LightLayer7 = 7,
    Layer8_Outline = 8, // Outline
    Layer9_GlitchMask = 9, // GlitchMask
    Layer10_ReflectionObjects = 10, // Reflection Objects
    Layer11_PlanarReflectionPlane = 11, // Planar Reflection Plane
    Layer12_WaterReflectionPlane = 12, // Water Reflection Plane
    Layer13_Blur = 13, // Blur
    Layer14_UIBlur = 14, // UI Blur
    Layer15_Backface = 15, // Backface
    Layer16_BlendTerrain = 16, // BlendTerrain
    Layer17_HairShadow = 17, // Hair Shadow
    Layer18_ToonMask = 18, // Toon Mask
    Layer19_HQShadow = 19, // High Quality Shadow
    Layer20_SelectOutline = 20, //SelectOutline
    Layer21_OutlineShake = 21, //OutlineShake

    // Layer28_CustomLightNormal = 28, // CustomLight Normal
    // Layer29_CustomLightGround = 29, // CustomLight Ground
    // Layer30_CustomLightBackground = 30, // CustomLight Background
    Layer30_MRT = 30, // CustomLight Character
    Layer31_CustomLightCharacter = 31, // CustomLight Character
}
