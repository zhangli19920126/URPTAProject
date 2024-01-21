Shader "urpshaders/character/character_toonlit"
{
    Properties
    {
        _BaseSettings( "# 【基础】设置", Float) = 1
            [HDR] _BaseColor("【固有色】", Color) = (1, 1, 1, 1)
            _BaseMap("【固有色】贴图 &", 2D) = "white" {}
            _SpecularIntensity("【高光】强度", Range(0, 1)) = 1
            _SpecularPow("【高光】大小", Range(16, 128)) = 32
            _ViewWidth("【视角光】大小", Range(0.0, 1.0)) = 0.1
            _ViewIntensity("【视角光】强度", Range(0.0, 1.0)) = 1
        
        _SSSSettings( "# 【SSS】设置", Float) = 1
            _SSS("【SSS】暗部值", Range(0, 0.8)) = 0.5
            _SSSMap("【SSS】暗色控制贴图 &", 2D) = "white" {}
            _SSSScale("【SSS】强度(0)", Range(0.0, 1.0)) = 0
        
        _ILMSettings( "# 【ILM】设置", Float) = 1
            _ILMInfoSettings( "!NOTE R-高光强度 G-光滑度 B-明暗阈值 A-自发光", Float) = 1 
            _ILMMap("【材质贴图】 &", 2D) = "white" {}
            //_Metallic("【金属度】强度(0.5)", Range(0.0, 2.0)) = 0.5
            //_Smoothness("【光滑度】强度(0.5)", Range(0.0, 2.0)) = 0.5
            //_Occlusion("【AO】强度(1)", Range(0.0, 1.0)) = 1.0
            _SpecularColor("【高光】颜色", Color) = (1, 1, 1, 1)
            _SpecularScale("【主高光】强度(1)", Range(0, 100)) = 1
            //_MinorSpecularScale("【副高光】强度(1)", Range(0, 100)) = 0
        
        _RimSettings("# 【Rim】设置", Float) = 1
            [Toggle(_RIM_ON)] _RimOn("【边缘光】开关", Float) = 0
            _RimWidth("【边缘光】宽度 [_RimOn]", Range(0.0, 0.3)) = 0.1
            _RimIntensity("【边缘光】强度 [_RimOn]", Range(0.0, 1.0)) = 0.5
            [Toggle(_RIMONLYDARK)] _RimOnlyDark("【仅暗部有】 [_RimOn]", Float) = 0
             
        
        _NormalMapSettings( "# 【法线贴图】设置", Float) = 1
            [Toggle(_NORMALMAP)] _EnableNormalMap("【法线贴图】开关", Float) = 0
            _NormalMap("【法线贴图】 &", 2D) = "bump" {}
            _NormalMapScale("【法线贴图】凹凸强度(1)", Range(0.0, 2.0)) = 1
        
        _OutlineSettings("# 【描边】设置", Float) = 1
            _OutLineColor("【描边】颜色", Color) = (1,1,1,1)
            _OutLineWidth("【描边】宽度", Range(0.0, 1.0)) = 0.1
        
        _DebugTexture("# 【贴图】查看", Float) = 1
            [Toggle(_DEBUG_TEX_ON)] _EnableDebugTex("【贴图】开关", Float) = 0.0
            _DebugTex("【贴图】 & [_EnableDebugTex]", 2D) = "white" {}
            [KeywordEnum(R, G, B, A, NONE)] _DebugTexMode("【贴图】通道 [_EnableDebugTex]", Float) = 3
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry" "RenderPipeline" = "UniversalPipeline"}
        LOD 100

        Pass
        {
            Name "character_toonlit"
            Tags{"LightMode" = "UniversalForward"}
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _DEBUG_TEX_ON
            #pragma shader_feature_local _DEBUGTEXMODE_NONE _DEBUGTEXMODE_R _DEBUGTEXMODE_G _DEBUGTEXMODE_B _DEBUGTEXMODE_A
            #pragma shader_feature_local _RIM_ON
            #pragma shader_feature_local _RIMONLYDARK
            
            #include "../comm/toon_input.hlsl"



            ToonVaryings vert(ToonAttributes input)
            {
                ToonVaryings output = ToonForwardPassVertex(input);

                return output;
            }

            half4 frag(ToonVaryings input) : SV_Target
            {
                half4 finalColor = ToonGGXForwardPassFragment(input);
                
                #if defined(_DEBUG_TEX_ON)
                    finalColor = SAMPLE_TEXTURE2D(_DebugTex, sampler_DebugTex, input.uv.xy);
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
                
                return finalColor;
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Back

            HLSLPROGRAM

            // -------------------------------------
            // Material Keywords
            // #pragma shader_feature_local _ALPHATEST_ON
            // #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            // #pragma multi_compile_instancing
            // #pragma multi_compile _ DOTS_INSTANCING_ON

            // Custom Define

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            
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

            #include "../comm/toon_input.hlsl"
            

            OutlineVaryings vert (OutlineAttributes v)
            {
                OutlineVaryings o = OutlineNPassVertex(v);
                
                return o;
            }

            half4 frag (OutlineVaryings i) : SV_Target
            {
                return _OutLineColor;
            }
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "Needle.MarkdownShaderGUI"
}
