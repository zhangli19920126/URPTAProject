#ifndef TOON_LIT_CBUFF_INCLUDED
#define TOON_LIT_CBUFF_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _SSSMap_ST;
    float4 _ILMMap_ST;

#ifdef _DEBUG_TEX
    float4 _DebugTex_ST;
#endif

    float4 _OutLineColor;

    float _SSS;
    float _SSSScale;
    float _SpecularIntensity;
    float _SpecularPow;
    float _ViewWidth;
    float _ViewIntensity;
    float _OutLineWidth;
    float _RimWidth;
    float _RimIntensity;
  
CBUFFER_END

#endif