#ifndef NPR_DATA_INCLUDED
#define NPR_DATA_INCLUDED

struct NPRAttributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 texcoord2    : TEXCOORD1;
    float4 color         : COLOR;
};

struct NPRVaryings
{
    float2 uv                       : TEXCOORD0;
    float3 positionWS               : TEXCOORD1;
    float3 tangenWS                 : TEXCOORD2;
    float3 viewDirWS                : TEXCOORD3;
    float3 normalWS                 : TEXCOORD4;
    float4 uv2                      : TEXCOORD5;
    half4 color                     : TEXCOORD6;
    float4 positionCS               : SV_POSITION;
};

struct OutlineAttributes
{
    float4 positionOS   : POSITION;
    float4 tangentOS    : TANGENT;
    float4 color        : COLOR;
};

struct OutlineVaryings
{
    float4 positionCS               : SV_POSITION;
};

#endif