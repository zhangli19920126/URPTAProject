#ifndef NPR_INPUT_INCLUDED
#define NPR_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "npr_data.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _LightMap_ST;
    float4 _LineMap_ST;
    float4 _MixMap_ST;
    float4 _ShadowMap_ST;
    float4 _DecalMap_ST;
    float4 _OutLineColor;
    float _LightThreshold;
    float _LineIntensity;
    float _DarkIntensity;
    float _SpecularIntensity;
    float _SpecularPowerValue;
    float _MetallicStepSpecularIntensity;
    float _MetallicStepSpecularWidth;
    float _LeatherStepSpecularWidth;
    float _LeatherStepSpecularIntensity;
    float _CommonStepSpecularWidth;
    float _CommonStepSpecularIntensity;
    float _RimWidth;
    float _RimIntensity;
    float _OutLineWidth;
CBUFFER_END

TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
TEXTURE2D(_LightMap);   SAMPLER(sampler_LightMap);
TEXTURE2D(_LineMap);   SAMPLER(sampler_LineMap);
TEXTURE2D(_MixMap);   SAMPLER(sampler_MixMap);
TEXTURE2D(_ShadowMap);   SAMPLER(sampler_ShadowMap);
TEXTURE2D(_DecalMap);   SAMPLER(sampler_DecalMap);

NPRVaryings NPRForwardPassVertex(NPRAttributes input)
{
    NPRVaryings output = (NPRVaryings)0;

    output.uv.xy = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.uv2.xy = input.texcoord2;
    output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.positionCS = TransformWorldToHClip(output.positionWS);
    output.viewDirWS = SafeNormalize(GetCameraPositionWS() - output.positionWS);
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    output.tangenWS = TransformObjectToWorldDir(input.tangentOS);
    output.color = input.color;

    return output;
}

OutlineVaryings OutlinePassVertex(OutlineAttributes input)
{
    OutlineVaryings output = (OutlineVaryings)0;
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz + input.tangentOS * _OutLineWidth * 0.01 * input.color.a);
    return output;
}

#endif