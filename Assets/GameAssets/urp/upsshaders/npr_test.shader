
Shader "URP/NPR/test"
{
    Properties
    {
        _Threshold("Threshold", Range(0,1)) = 0.5
        _DarkCcolr("DarkColr", Color) = (0,0,0,1) 
        _RightColor("RightColol", Color) = (1,1,1,1)
        
        [Space(20)]
        _SpecularIntensity("phong高光强度",Range(0,10)) = 1
        _SpecularPowerValue("phong高光曲率",Range(0,90)) = 32
        
        [Space(20)]
        _RimIntensity("边缘光强度",Range(0,10)) = 1
        _RimExp("边缘光曲率",Range(0,90)) = 32
        _RimWidth("边缘光宽", Range(0, 1)) = 0.1
        
        [Space(20)]
        _OutlineColor("描边颜色", Color) = (1,1,1,1)
        _OutlineWidth("描边宽", Range(0,1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
        LOD 100

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                
            };

            struct Varyings
            {
                
                float3 normalWS     : TEXCOORD0;
                float3 positionWS   : TEXCOORD1;
                float3 viewDirWS    : TEXCOORD2;
                float4 positionCS   : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _DarkCcolr;
            float4 _RightColor;
            float4 _OutlineColor;
            float _Threshold;
            float _SpecularIntensity;
            float _SpecularPowerValue;
            float _RimExp;
            float _RimIntensity;
            float _RimWidth;
            CBUFFER_END
            
            TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionWS = TransformObjectToWorld(v.positionOS);
                o.viewDirWS = GetCameraPositionWS() - o.positionWS;
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                //normalize
                float3 L = normalize(GetMainLight().direction);
                float3 N = normalize(i.normalWS);
                float3 V = normalize(i.viewDirWS);
                
                //diffuse
                
                float NL01 = dot(N, L) * 0.5 + 0.5;
                float threshold = step(1-_Threshold, NL01);
                float3 diffuse = lerp(_DarkCcolr, _RightColor, threshold);

                //specular
                float3 H = normalize(V + L);
                float NH = saturate(dot(N, H));
                float3 specular = pow(NH, _SpecularPowerValue) * _SpecularIntensity;
                //float specular = step(1 - _SpecularPowerValue * 0.01, NH) * _SpecularIntensity; //裁边高光

                //Rim
               // float NV = saturate(dot(i.normalWS, i.viewDirWS));
                float NV = dot(N, V);
                //float Rim = pow(1-NV, _RimExp) * _RimIntensity;
                float3 rim = step(NV, _RimWidth) * _RimIntensity;

                float3 finalColor = NV /2;
                return half4(rim, 1); 
            }
            ENDHLSL
        }
        
        Pass
        {
            Name "Outline"
            Tags {"LightMode" = "OutLine"}
            Cull Front
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"


            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS   : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _OutlineColor;
            float _OutlineWidth;
            CBUFFER_END

            Varyings vert (Attributes v)
            {
                Varyings output = (Varyings)0;
                output.positionCS = TransformObjectToHClip(v.positionOS.xyz + v.normalOS * _OutlineWidth * 0.01);
                return output;
            }

            half4 frag (Varyings i) : SV_Target
            {
                return _OutlineColor;
            }
            
            ENDHLSL
        }
    }
}
