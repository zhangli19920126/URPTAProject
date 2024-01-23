Shader "urpshaders/character/character_toonlit"
{
    Properties
    {
        _BaseSettings( "# 【基础】设置", Float) = 1
            _BaseMap("【固有色】贴图 &", 2D) = "white" {}
            
            [Toggle(_RAMPMAP_NO)] _EnableRamPMap("【Ramp】贴图", Float) = 0
            _RampMap("【Ramp】贴图 & [_RAMPMAP_NO]", 2D) = "white" {}
            _RampOffset ("【明暗】偏移",Range(-3,3)) =0
            _DarkIntensity("【暗部】强度",Range(0,2)) =0.5
            _BrightIntensity("【亮部】强度",Float) =1
            [Toggle(_USE_SECOND_DARK)] _UseSecondDark("【二级暗部】开关", Float) = 0.0
            _RampOffset2 ("【二级暗部】偏移 [_UseSecondDark]",Range(-2,2)) =0
            _DarkIntensity2("【二级暗部】强度 [_UseSecondDark]",Range(0,2)) =0.5
        
        _AOSetting("# 【AO】设置", Float) = 1
            _AOInfoSettings( "!NOTE AO贴图信息：R-RampAdd G-AO B-高光Mask A-NoUse", Float) = 1 
            _LightMap("【AO】贴图 &", 2D) = "black" {}
            [Toggle(_AO_RAMP_NO)] _EnableAORamp("【AO】影响Ramp", Float) = 0
            _RampAddScale ("【RampAdd】强度 [_AO_RAMP_NO]",Range(-1,1)) = 1
            [Toggle(_AO_SPEC_NO)] _EnableSpecRamp("【AO】影响高光", Float) = 0
            
        
        _PBRSettings( "# 【PBR/ILM】设置", Float) = 1
            _PbrInfoSettings( "!NOTE R-PBR时为金属度/NPR时为高光强度 G-光滑度 B-明暗阈值 A-PBR时为材质区分/自发光", Float) = 1 
            [KeywordEnum(None,GGX,BlinPhong)] _SpecType("高光类型", Float) = 1
            _PbrMixMap("【PBR/ILM】贴图 & [!_SPECTYPE_NONE || _USE_SECOND_DARK]", 2D) = "black" {}
            //ggx高光
            _Roughness("【粗糙度】 [!_SPECTYPE_NONE && _SPECTYPE_GGX]",Range(0,1)) =0.5
            _Metallic("【金属度】 [!_SPECTYPE_NONE && _SPECTYPE_GGX]",Range(0,1)) =0.1
            _SpecularIntensity("【高光】强度 [!_SPECTYPE_NONE && _SPECTYPE_GGX]",Float) = 1
            //phong高光
            _Shininess("【高光】大小 [!_SPECTYPE_NONE && _SPECTYPE_BLINPHONG]",Float) = 1
            _Gloss("【高光】强度 [!_SPECTYPE_NONE && _SPECTYPE_BLINPHONG]",Float) = 1
            //phong形变
            [Toggle(_PHONG_SHIFT_ON)] _Phong_Shift_On("【高光形变】开关 [!_SPECTYPE_NONE && _SPECTYPE_BLINPHONG]", Float) = 0
            _Threshold("【形变】阈值 [!_SPECTYPE_NONE && _SPECTYPE_BLINPHONG]",Float) = 0.2
            _SpecShiftIntensity("【形变】后强度控制 [!_SPECTYPE_NONE && _SPECTYPE_BLINPHONG]",Float) =1
            //二级视角高光
            [Toggle(_SPECULAR_STEP)] _StepLightOn("【二层高光】开关", Float) = 0
            _StepLightWidth("宽度 [_StepLightOn]",Float) = 0.3
            _StepLightIntensity("强度 [_StepLightOn]",Float) = 1
        
        _NormalMapSettings( "# 【法线贴图】设置", Float) = 1
            [Toggle(_NORMALMAP_NO)] _EnableNormalMap("【法线贴图】开关", Float) = 0
            _NormalMap("【法线贴图】 & [_NORMALMAP_NO]", 2D ) = "bump" {}
            _NormalScale("【法线贴图】凹凸强度(10) [_NORMALMAP_NO]", Range(0.0, 2.0)) = 1
        
        _RimSettings("# 【Rim】设置", Float) = 1
            [Toggle(_RIM_ON)] _RimOn("【边缘光】开关", Float) = 0
            _RimWidth("【边缘光】宽度 [_RimOn]", Range(0.0, 0.3)) = 0.1
            _RimIntensity("【边缘光】强度 [_RimOn]", Range(0.0, 1.0)) = 0.5
            [Toggle(_RIMONLYDARK)] _RimOnlyDark("【仅暗部有】 [_RimOn]", Float) = 0
        
        _OutlineSettings("# 【描边】设置", Float) = 1
            _OutLineColor("【描边】颜色", Color) = (1,1,1,1)
            _OutLineWidth("【描边】宽度", Range(0.0, 1.0)) = 0.1
        
        _StencilSettings( "# 【模板测试】设置", Float) = 1
            [IntRange] _StencilRef("Stencil Reference Value", Range(0, 8)) = 1
            [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comparison", Int) = 8
            [Enum(UnityEngine.Rendering.StencilOp)] _StencilOp("Stencil Operation", Int) = 2 
        
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
            
            Stencil
			{
                Ref [_StencilRef]
                Comp [_StencilComp] // Always
                Pass [_StencilOp]   
            }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #pragma shader_feature_local _USE_SECOND_DARK
            #pragma shader_feature_local _AO_RAMP_NO
            #pragma shader_feature_local _AO_SPEC_NO
            #pragma shader_feature_local _SPECTYPE_NONE _SPECTYPE_GGX _SPECTYPE_BLINPHONG
            #pragma shader_feature_local _PHONG_SHIFT_ON
            #pragma shader_feature_local _SPECULAR_STEP
            #pragma shader_feature_local _RAMPMAP_NO
            #pragma shader_feature_local _NORMALMAP_NO
            #pragma shader_feature_local _RIM_ON
            #pragma shader_feature_local _RIMONLYDARK
            #pragma shader_feature_local _DEBUG_TEX_ON
            #pragma shader_feature_local _DEBUGTEXMODE_NONE _DEBUGTEXMODE_R _DEBUGTEXMODE_G _DEBUGTEXMODE_B _DEBUGTEXMODE_A
            
            #include "../comm/toon_input.hlsl"

            ToonVaryings vert(ToonAttributes input)
            {
                ToonVaryings output = ToonForwardPassVertex(input);

                return output;
            }

            half4 frag(ToonVaryings input) : SV_Target
            {
                ToonLightData toonData = InitToonLightData(input);
                half4 finalColor = ToonForwardPassFragment(toonData);
                TexDebug(finalColor, input.uv);
                return finalColor;
            }
            ENDHLSL
        }

        //透射阴影
//        Pass
//        {
//            Name "ShadowCaster"
//            Tags{"LightMode" = "ShadowCaster"}
//
//            ZWrite On
//            ZTest LEqual
//            ColorMask 0
//            Cull Back
//
//            HLSLPROGRAM
//
//            // -------------------------------------
//            // Material Keywords
//            // #pragma shader_feature_local _ALPHATEST_ON
//            // #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
//
//            //--------------------------------------
//            // GPU Instancing
//            // #pragma multi_compile_instancing
//            // #pragma multi_compile _ DOTS_INSTANCING_ON
//
//            // Custom Define
//
//            #pragma vertex ShadowPassVertex
//            #pragma fragment ShadowPassFragment
//
//            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
//            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
//            
//            ENDHLSL
//        }


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
