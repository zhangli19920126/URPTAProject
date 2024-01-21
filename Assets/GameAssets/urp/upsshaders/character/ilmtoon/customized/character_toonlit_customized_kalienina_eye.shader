Shader "urpshaders/character/customized/character_toonlit_customized_kalienina_eye"
{
    Properties
    {
        _BaseSettings( "# 【基础】设置", Float) = 1
            _BaseMap("【固有色】贴图 &", 2D) = "white" {}
            _RampOffset ("【明暗】偏移",Range(-1,1)) =0
            _DarkIntensity("【暗部】强度",Range(0,1)) =0.5
            _BrightIntensity("【亮部】强度",Float) =1
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline"}
        LOD 100

        Pass
        {
            Name "character_toonlit_customized_kalienina"
            Tags{"LightMode" = "UniversalForward"}
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "../../comm/toon_data.hlsl"
            #include "../../../common/TABrdf.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                half _RampOffset;
                half _DarkIntensity;
                half _BrightIntensity;
            CBUFFER_END

            TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
            
            

            ToonVaryings vert(ToonAttributes input)
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

            float4 frag(ToonVaryings input):SV_Target
            {
                float4 finalColor = 0;
                
                float2 uv = input.uv.xy;
                float4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv);
                
                //light
                Light mainLight = GetMainLight(input.shadowCoord, input.positionWS, float4(0,0,0,0));

                float3 N    = normalize(input.normalWS);
                float3 L    = normalize(mainLight.direction);
            
                float NL = dot(N,L);
                float NL01 = NL * 0.5 + 0.5;

                //Diffuse
                float3 brightSide = baseMap * _BrightIntensity;
                float3 darkSide = baseMap * _DarkIntensity;
                float threshold = step(_RampOffset, NL);
                float3 diffuse = lerp(darkSide, brightSide, threshold);

                
                finalColor.xyz = diffuse;
                return finalColor;
            }

            ENDHLSL
        }
        
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "Needle.MarkdownShaderGUI"
}
