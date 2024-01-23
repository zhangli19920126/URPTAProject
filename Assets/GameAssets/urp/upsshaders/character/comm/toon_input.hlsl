#ifndef NPR_INPUT_INCLUDED
#define NPR_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "toon_data.hlsl"
#include "toon_lit_cbuffer.hlsl"
#include "../../common/TABrdf.hlsl"

TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
TEXTURE2D(_LightMap);   SAMPLER(sampler_LightMap);
TEXTURE2D(_PbrMixMap);   SAMPLER(sampler_PbrMixMap);

#ifdef _RAMPMAP_NO
TEXTURE2D(_RampMap);   SAMPLER(sampler_RampMap);
#endif

//#ifdef _NORMALMAP_NO
TEXTURE2D(_NormalMap);   SAMPLER(sampler_NormalMap);
//#endif

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

ToonLightData InitToonLightData(ToonVaryings input)
{
    ToonLightData data = (ToonLightData)0;
    
    Light light = GetMainLight(input.shadowCoord, input.positionWS, float4(0,0,0,0));
    float2 uv = input.uv.xy;
    
    data.baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
    data.lightMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, uv);
    data.mixMap = SAMPLE_TEXTURE2D(_PbrMixMap, sampler_PbrMixMap, uv);
    
    data.T    = normalize(input.tangentWS);
    data.N    = normalize(input.normalWS);
    data.B    = normalize(input.bitangentWS);
    data.L    = normalize(light.direction);
    //float3 V = normalize(input.viewDirWS);
    data.V = normalize(GetWorldSpaceViewDir(input.positionWS));
    data.H = normalize(data.V+data.L);//半角向量

    #ifdef _NORMALMAP_NO
    float3 normalMap = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv), _NormalScale);
    //TBN矩阵:将世界坐标转到Tangent坐标，（是正交矩阵，逆等于其转置）
    float3x3 TBN = float3x3(data.T, data.B, data.N);
    //将NormalMap 从Tangent坐标转到世界坐标
    data.N = normalize(mul(normalMap, TBN));  // N = normalize(mul(inverse(TBN), NormalMap));
    #endif
            
    data.HV = saturate(dot(data.H, data.V));
    data.NV = saturate(dot(data.N, data.V));
    data.NL = saturate(dot(data.N, data.L));
    data.NH = saturate(dot(data.N, data.H));
    data.TL = saturate(dot(data.T, data.L));
    data.TH = saturate(dot(data.T, data.H));
    data.NL01 = data.NL * 0.5 + 0.5;

    #ifdef _RAMPMAP_NO
    float shadowAO = step(0.1, data.lightMap.g);
    data.rampMap = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2((data.NL01 + _RampOffset) * shadowAO, 0.5));
    #endif
    
    data.uv1 = uv;
    data.uv2 = input.uv2;
    data.light = light;

    return data;
}

half4 ToonForwardPassFragment(ToonLightData input)
{
    half3 finalColor = input.baseColor.xyz;
    half3 baseColor = input.baseColor.xyz;
    half4 mixMap = input.mixMap;

    half3 dark = baseColor * _DarkIntensity;
    half3 bright = baseColor * _BrightIntensity;
    half3 diffuse = 0;

    float GGXMask = mixMap.a;
    float matMask = 1; //材质区分
    if(GGXMask < 0.2 || GGXMask > 0.44)
        matMask = 0;
    if(GGXMask > 0.76)
        matMask = 1;
    
    float threshold = 0;
    float rampAdd = 0;
    
    #ifdef _AO_RAMP_NO
    rampAdd = input.lightMap.r * 2 - 1;
    rampAdd *= _RampAddScale;
    #endif
    
    
    #ifdef _RAMPMAP_NO
        diffuse = lerp(dark, bright, input.rampMap.xyz);
        threshold = input.rampMap.x;
    #else
        float shadowAO = input.lightMap.g;
        shadowAO = step(0.01, shadowAO);
        threshold = step(_RampOffset + rampAdd, input.NL) * shadowAO;
        diffuse = lerp(dark, bright, threshold);
        
        #ifdef _USE_SECOND_DARK
        float threshold2 =  step(((_RampOffset2 + rampAdd) * shadowAO), input.NL);
        float3 second = lerp(baseColor * _DarkIntensity2, diffuse, threshold2);
        diffuse = lerp(diffuse, second, matMask);
        #endif
    #endif

    finalColor.xyz = diffuse;
    
    float3 specular = 0;
    
    #ifdef _SPECTYPE_GGX
        float metallic = mixMap.r; //金属度
        float roughness = 1 - mixMap.g; //粗糙度
        float AO = mixMap.b;     
        metallic *= _Metallic;
        roughness *= _Roughness;
        float3 F0 = lerp(0.04, input.baseColor, metallic);
        specular =  Specular_GGX(input.N,input.L,input.H,input.V,roughness,F0) * AO *_SpecularIntensity * GGXMask *matMask;
    #elif _SPECTYPE_BLINPHONG
        #ifdef _PHONG_SHIFT_ON
            StylizedSpecularParam param;
            param.BaseColor = baseColor;
            param.Normal = input.N;
            param.Shininess = _Shininess;
            param.Gloss = _Gloss;
            param.Threshold = _Threshold;
            param.dv = input.T;
            param.du = input.B;
            specular =  StylizedSpecularLight_BlinPhong( param, input.H)*_SpecShiftIntensity* GGXMask*matMask;
        #else
            specular = pow(input.NH, _Shininess*128) *_Gloss;
        #endif
    #endif

    #ifdef _AO_SPEC_NO
    specular *= input.lightMap.b;
    #endif

    finalColor += specular;

    //自发光
    #ifdef _RIM_ON
        half rimStep = step(input.NV, _RimWidth);
        #ifdef _RIMONLYDARK
        rimStep = lerp(rimStep, 0, threshold);
        #endif
        float3 rim = rimStep * _RimIntensity * baseColor;
        finalColor += rim;
    #endif

    
    #ifdef _SPECULAR_STEP
        float3 stepLight = step(1 - _StepLightWidth, input.NH) * _StepLightIntensity * baseColor;
        finalColor += stepLight;
    #endif

    return half4(finalColor, 1);
}

half4 TexDebug(half4 srcColor, float2 uv)
{
    #if defined(_DEBUG_TEX_ON)
        srcColor = SAMPLE_TEXTURE2D(_DebugTex, sampler_DebugTex, uv);
        #if defined(_DEBUGTEXMODE_R)
            finalColor = finalColor.rrrr;
        #elif defined(_DEBUGTEXMODE_G)
            finalColor = finalColor.gggg;
        #elif defined(_DEBUGTEXMODE_B)
            finalColor = finalColor.bbbb;
        #elif defined(_DEBUGTEXMODE_A)
            finalColor = finalColor.aaaa;
        #endif
    #endif
    
    return srcColor;
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