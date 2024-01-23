#ifndef TOON_LIT_CBUFF_INCLUDED
#define TOON_LIT_CBUFF_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _LightMap_ST;
    float4 _PbrMixMap_ST;

    //#ifdef _RAMPMAP_NO
    float4 _RampMap_ST;
    //#endif

    //#ifdef _NORMALMAP_NO
    float4 _NormalMap_ST;
    //#endif

    //#ifdef _DEBUG_TEX
    float4 _DebugTex_ST;
    //#endif

    half4 _OutLineColor;

    half _StepLightWidth;
    half _StepLightIntensity;
    half _RampOffset;
    half _DarkIntensity;
    half _BrightIntensity;
    half _RampOffset2;
    half _RampAddScale;
    half _DarkIntensity2;
                
    half _Roughness;
    half _Metallic;
    half _SpecularIntensity;
    half _SpecularStep;
    half _SpecShiftIntensity;
    half _Shininess;
    half _Gloss;
    half _Threshold;
                
    //#ifdef _NORMALMAP_NO
    half _NormalScale;
    //#endif
                
    half _RimWidth;
    half _RimIntensity;
                
    half _OutLineWidth;
CBUFFER_END

#endif