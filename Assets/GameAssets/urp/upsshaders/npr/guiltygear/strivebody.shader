Shader "URP/NPR/strivebody"
{
    Properties
    {
        _BaseMap    ("_BaseMap", 2D)    = "white" {}
        _LightMap   ("_LightMap", 2D)   = "white" {}
        _LineMap    ("_LineMap", 2D)    = "white" {}
        _MixMap     ("_MixMap", 2D)     = "black" {}
        _ShadowMap  ("_ShadowMap", 2D)  = "white" {}
        _DecalMap   ("_DecalMap", 2D)   = "white" {}
        
        [Space(20)]
        _LightThreshold("_LightThreshold",Range(-2,2))=0.5
        _DarkIntensity("暗部强度",Range(0,1)) = 0
        
        [Space(20)]
        _LineIntensity("损旧线条强度",Range(0,1)) = 0
        
        [Space(20)]
        _SpecularIntensity("phong高光强度",Range(0,10)) =1
        _SpecularPowerValue("phong高光曲率",Range(0,90)) = 32
        [Space(10)]
        _MetallicStepSpecularWidth("金属裁边视角宽度",Range(0,1)) =0.5
        _MetallicStepSpecularIntensity("金属裁边视角强度",Range(0,1)) =0.3
        [Space(10)]
        _LeatherStepSpecularWidth("皮革裁边视角光宽度",Range(0,1)) =0.5
        _LeatherStepSpecularIntensity("皮革裁边视角光强度",Range(0,1)) =0.3
        [Space(10)]
        _CommonStepSpecularWidth("普通材质 裁边高光宽度",Range(0,1)) =0.5
        _CommonStepSpecularIntensity("普通材质 裁边高光强度",Range(0,1)) =0.3
        
        [Space(20)]
        _RimWidth("边缘光宽度",Range(0,1)) =0.5
        _RimIntensity("边缘光强度",Range(0,1)) =0.3
        
        [Space(20)]
        _OutLineWidth ("_OutLineWidth", Range(0,40)) = 6
        _OutLineColor ("_OutLineColor", Color) = (0.0,0.0,0.0,1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
        LOD 100

        Pass
        {
            Name "NPRBody"
            Tags{"LightMode" = "UniversalForward"}
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "../comm/npr_input.hlsl"
            

            NPRVaryings vert (NPRAttributes v)
            {
                NPRVaryings o = NPRForwardPassVertex(v);
                return o;
            }

            half4 frag (NPRVaryings i) : SV_Target
            {
                float3 N = i.tangenWS;
                float3 L = normalize(GetMainLight().direction);
                float3 V = normalize(i.viewDirWS);
                float3 T = i.tangenWS;
                float3 B = normalize(cross(N,T));
                float3 H = normalize(L+V);

                float4 BaseMap      = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap, i.uv);
                float4 LightMap     = SAMPLE_TEXTURE2D(_LightMap,sampler_LightMap, i.uv);
                float4 LineMap      = SAMPLE_TEXTURE2D(_LineMap,sampler_LineMap, i.uv);
                float4 MixMap       = SAMPLE_TEXTURE2D(_MixMap,sampler_MixMap, i.uv);
                float4 ShadowMap    = SAMPLE_TEXTURE2D(_ShadowMap,sampler_ShadowMap, i.uv);
                float4 DecalMap     = SAMPLE_TEXTURE2D(_DecalMap,sampler_DecalMap, i.uv);

                float4 VertexColor              = i.color;
                float ShadowAOMask              = VertexColor.r > 0.5;  //AO 常暗部分
                float layerMask                 = LightMap.r;           //材质类型
                float RampOffsetMask            = LightMap.g *2-1;      //Ramp偏移值  //值域重新映射 [0,1]-> [-1,1]
                float specularIntensityMask     = LightMap.b;           //高光强度mask
                float InnerLineMask             = LightMap.a;           //内勾线Mask

                float3 finalColor = 0;
                float NL = dot(N, L);
                float NV = dot(N, V);
                float NH = dot(N, H);

                //diffuse
                float NL01 = NL*0.5 + 0.5;
                float threshold = step(_LightThreshold, (NL01 + RampOffsetMask) * ShadowAOMask);
                BaseMap*= InnerLineMask; //内勾线
                BaseMap = lerp(BaseMap,BaseMap*LineMap,_LineIntensity); //旧损线
                float3 brightSide = BaseMap;//亮部色
                float3 darkSide = lerp(ShadowMap*BaseMap, BaseMap, _DarkIntensity); //暗部色 = ShadowMap*BaseMap
                float3 diffuse = lerp( darkSide,brightSide,threshold);
                //return half4(diffuse, 1);

                //rim
                float3 n_VS = mul((float3x3)UNITY_MATRIX_V, N);
                //float3 rim = step(1-_RimWidth, abs(n_VS.x)) * _RimIntensity * BaseMap;
                float3 rim = step(NV, _RimWidth) * _RimIntensity * BaseMap;
                rim = lerp(rim, 0, threshold);

                float3 specular =0;
                specular = pow(saturate(NH),_SpecularPowerValue)*_SpecularIntensity * specularIntensityMask*BaseMap;//传统高光
                //specular = step(1 - _SpecularPowerValue * 0.01, NH) * _SpecularIntensity * SpecularIntensityMask*BaseMap; //裁边高光
                specular = max(specular,0);

                float specularIntensity = specularIntensityMask*255;
                float layer = max(layerMask * 255, 0);
                if(layer <= 60) //裁边视角光
                {
                    float stepSpecularMask = float(specularIntensity>0  && specularIntensity<180);
                    float3 leatherSpecular = step(1-_CommonStepSpecularWidth,NV)*_CommonStepSpecularIntensity*BaseMap * stepSpecularMask;
                    leatherSpecular = max(0,leatherSpecular);
                    specular = lerp(specular, leatherSpecular, stepSpecularMask);
                    //return 0;
                    //return float4(specular,1);
                }
                else if(layer<190) //皮革裁边视角光
                {
                    float stepSpecularMask = float(specularIntensity>180);
                    float3 leatherSpecular = step(1-_LeatherStepSpecularWidth,NV)*_LeatherStepSpecularIntensity*BaseMap * stepSpecularMask;
                    leatherSpecular = max(0,leatherSpecular);
                    specular = lerp(specular, leatherSpecular,stepSpecularMask);
                    //return 0;
                    //return float4(specular,1);
                }
                else
                {
                    float3 metallicStepSpecular = step(abs(n_VS.x) , _MetallicStepSpecularWidth)*_MetallicStepSpecularIntensity*BaseMap; //裁边视角光(模拟反射,ViewSpace)
                    metallicStepSpecular = max(0,metallicStepSpecular);
                    specular += metallicStepSpecular;
                    //return 1;
                    //return float4(specular,1);
                }
                
                finalColor = diffuse + rim + specular;
                
                return half4(finalColor, 1);
            }
            ENDHLSL
        }
        
        Pass
        {
            Name "Outline"
            Tags{"LightMode" = "Outline"}
            cull front
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "../comm/npr_input.hlsl"
            

            OutlineVaryings vert (OutlineAttributes v)
            {
                OutlineVaryings o = OutlinePassVertex(v);
                
                return o;
            }

            half4 frag (NPRVaryings i) : SV_Target
            {
                return _OutLineColor;
            }
            ENDHLSL
        }
    }
}
