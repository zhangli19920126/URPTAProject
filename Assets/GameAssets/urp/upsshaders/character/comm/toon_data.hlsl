#ifndef NPR_DATA_INCLUDED
#define NPR_DATA_INCLUDED
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct ToonAttributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 texcoord2    : TEXCOORD1;
    float4 color         : COLOR;
};

struct ToonVaryings
{
    float4 positionCS               : SV_POSITION;
    float4 uv                       : TEXCOORD0;
    float4 shadowCoord              : TEXCOORD1;
    float4 uv2                      : TEXCOORD2;
    float4 screenPos                : TEXCOORD3;
    float4 positionOS               : TEXCOORD4;

    float3 positionWS               : TEXCOORD5;
    float4 viewDirWS                : TEXCOORD6;
    float3 normalWS                 : TEXCOORD7;
//#ifdef _NORMALMAP
    float3 tangentWS                : TEXCOORD8;
    float3 bitangentWS              : TEXCOORD9;
//#endif
    half4 color                     : TEXCOORD10;
    
};

struct ToonLightData
{
    Light light;

    float4 baseColor;
    float4 lightMap;
    float4 mixMap;
    
    #ifdef _RAMPMAP_NO
    float4 rampMap;
    #endif
    
    
    float3 T;
    float3 B;
    float3 N;
    float3 L;
    float3 V;
    float3 H;
    float2 uv1;
    float2 uv2;

    float NV;
    float NL;
    float NH;
    float TL;
    float TH;
    float HV;
    float NL01;
};

struct OutlineAttributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float4 color        : COLOR;
};

struct OutlineVaryings
{
    float4 positionCS               : SV_POSITION;
};

#endif