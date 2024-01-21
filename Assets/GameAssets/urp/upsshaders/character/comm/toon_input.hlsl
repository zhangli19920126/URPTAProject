#ifndef NPR_INPUT_INCLUDED
#define NPR_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "toon_data.hlsl"
#include "toon_lit_cbuffer.hlsl"

TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
TEXTURE2D(_SSSMap);   SAMPLER(sampler_SSSMap);
TEXTURE2D(_ILMMap);   SAMPLER(sampler_ILMMap);

#ifdef _DEBUG_TEX_ON
TEXTURE2D(_DebugTex);   SAMPLER(sampler_DebugTex);
#endif


ToonVaryings ToonForwardPassVertex(ToonAttributes input)
{
    ToonVaryings output = (ToonVaryings)0;

    output.uv.xy = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.uv2.xy = input.texcoord2;

    output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.positionCS = TransformWorldToHClip(output.positionWS);
    output.viewDirWS.xyz = GetCameraPositionWS() - output.positionWS;
    output.viewDirWS.w = ComputeFogFactor(output.positionCS.z); //雾效
    
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    output.normalWS = float3(normalInput.normalWS);
    output.tangentWS = float3(normalInput.tangentWS);
    output.bitangentWS = float3(normalInput.bitangentWS);

    output.shadowCoord = TransformWorldToShadowCoord(output.positionWS);
    output.screenPos = ComputeScreenPos(output.positionCS);
    output.color = input.color;
    output.positionOS = input.positionOS;

    
    return output;
}

half4 ToonGGXForwardPassFragment(ToonVaryings input)
{
    float4 base = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv.xy);
    float4 sss = SAMPLE_TEXTURE2D(_SSSMap, sampler_SSSMap, input.uv.xy);
    //r材质区分 g常暗区域，b高光大小，a轮廓线
    float4 ilm = SAMPLE_TEXTURE2D(_ILMMap, sampler_ILMMap, input.uv.xy);
    half3 finalColor = base.xyz;
    //light
    Light mainLight = GetMainLight(input.shadowCoord, input.positionWS, float4(1,1,1,1));
    float fogFactor = input.viewDirWS.w;
    // float zCS = input.positionCS.z * input.positionCS.w;//将经过透视除法的顶点反推回裁剪空间
    // real fogFactor = ComputeFogFactor(zCS);
    
    //Variable
    float3 T = normalize(input.tangentWS);
    float3 N = normalize(input.normalWS);
    float3 B = normalize(cross(N,T));
    float3 L = normalize(mainLight.direction);
    //float3 V = normalize(input.viewDirWS);
    float3 V = normalize(GetWorldSpaceViewDir(input.positionWS));
    float3 H = normalize(V+L);//半角向量
    float2 uv = input.uv.xy;
    float2 uv2 = input.uv2.xy;

    //useful dot
    float HV = dot(H,V);
    float NV = dot(N,V);
    float NL = dot(N,L);
    float NH = dot(N,H);
    float TL = dot(T,L);
    float TH = dot(T,H);
    float NL01 = NL * 0.5 + 0.5;

    //漫反射
    base *= ilm.a;
    float alwaysDark = ilm.g > 0.01;
    float threshold = step(_SSS, NL01 * alwaysDark);
    half3 diffuse = lerp(base * _SSSScale, base, threshold).xyz;
    diffuse *= mainLight.color;

    half3 rim = 0;
#ifdef _RIM_ON
    //自发光
    half rimStep = step(NV, _RimWidth);
#ifdef _RIMONLYDARK
    rimStep = lerp(rimStep, 0, threshold);
#endif
    rim = rimStep * _RimIntensity * base.xyz;
#endif
    //法线转到视角空间下的做法
    // float3  N_VS = mul((float3x3)unity_MatrixV, N);
    // rim = step(1-_RimWidth, abs(N_VS.x)) * _RimIntensity * base;

    //高光
    half3 specular = pow(saturate(NH), _SpecularPow) * _SpecularIntensity  * base.xyz;
    // //视角光
    // float4 viewColor = step(1-_ViewWidth,NV)*_ViewIntensity*base;
    
    half layer = ilm.r * 255;//经过测试，0-60（即最暗的部分）对应角色普通材质，60到190对应角色皮革材质，190以上是金属材质。
    specular *= (layer > 190);
    
    finalColor = diffuse + specular + rim;
    finalColor = MixFog(finalColor.rgb, fogFactor);
    return half4(finalColor, 1);
}

OutlineVaryings OutlineTPassVertex(OutlineAttributes input)
{
    OutlineVaryings output = (OutlineVaryings)0;
    output.positionCS =  TransformObjectToHClip(input.positionOS.xyz + input.tangentOS.xyz * _OutLineWidth * 0.01);
    return output;
}

OutlineVaryings OutlineNPassVertex(OutlineAttributes input)
{
    OutlineVaryings output = (OutlineVaryings)0;
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz + input.normalOS * _OutLineWidth * 0.01);
    return output;
}


#endif