Shader "urpshaders/character/customized/character_toonlit_customized_kalienina_cloth_alpha"
{
    Properties
    {
        _BaseSettings( "# 【基础】设置", Float) = 1
            _BaseMap("【固有色】贴图 &", 2D) = "white" {}
            _LightMap("【AO】贴图 &", 2D) = "black" {}
            _LightThreshold ("【明暗】阈值",Range(-1,1)) =0
            _RampOffset ("【明暗】偏移",Range(-1,1)) =0
            _DarkIntensity("【暗部】强度",Range(0,1)) =0.5
            _BrightIntensity("【亮部】强度",Float) =1
            _Roughness("【粗糙度】",Range(0,1)) =0.5
            _Metallic("【金属度】",Range(0,1)) =0.1
            _SpecularIntensity("【高光】强度",Float) =1
        
        _NormalSettings("# 【法线贴图】设置", Float) = 1
            _NormalMap("【法线】贴图 &", 2D) = "bump" {}
            _NormalScale("贴图强度度", Range(0.0, 2.0)) = 1
        
        _RimSettings("# 【Rim】设置", Float) = 1
            [Toggle(_RIM_ON)] _RimOn("【边缘光】开关", Float) = 0
            _RimWidth("【边缘光】宽度 [_RimOn]", Range(0.0, 1)) = 0.1
            _RimIntensity("【边缘光】强度 [_RimOn]", Range(0.0, 1.0)) = 0.5
            [Toggle(_RIMONLYDARK)] _RimOnlyDark("【仅暗部有】 [_RimOn]", Float) = 0
        
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
            Name "character_toonlit_customized_kalienina"
            Tags{"LightMode" = "UniversalForward"}
            
            Blend SrcAlpha OneMinusSrcAlpha
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            
            #pragma shader_feature_local _DEBUG_TEX_ON
            #pragma shader_feature_local _DEBUGTEXMODE_NONE _DEBUGTEXMODE_R _DEBUGTEXMODE_G _DEBUGTEXMODE_B _DEBUGTEXMODE_A
            #pragma shader_feature_local _RIM_ON
            #pragma shader_feature_local _RIMONLYDARK
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "../../comm/toon_data.hlsl"
            #include "../../../common/TABrdf.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _NormalMap_ST;
                float4 _LightMap_ST;

            #ifdef _DEBUG_TEX
                float4 _DebugTex_ST;
            #endif

                half4 _OutLineColor;

                half _LightThreshold;
                half _RampOffset;
                half _DarkIntensity;
                half _BrightIntensity;
                half _NormalScale;
                half _Roughness;
                half _Metallic;
                half _SpecularIntensity;
                half _RimWidth;
                half _RimIntensity;
                half _OutLineWidth;
            CBUFFER_END

            TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap);   SAMPLER(sampler_NormalMap);
            TEXTURE2D(_LightMap);   SAMPLER(sampler_LightMap);

        #ifdef _DEBUG_TEX_ON
            TEXTURE2D(_DebugTex);   SAMPLER(sampler_DebugTex);
        #endif
            

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
                float4 lightMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, uv);
                float3 normalMap = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv), _NormalScale);
                
                
                //light
                Light mainLight = GetMainLight(input.shadowCoord, input.positionWS, float4(0,0,0,0));

                float3 T    = normalize(input.tangentWS);
                float3 N    = normalize(input.normalWS);
                float3 B    = normalize(input.bitangentWS);
                float3 L    = normalize(mainLight.direction);
                //float3 V = normalize(input.viewDirWS);
                float3 V = normalize(GetWorldSpaceViewDir(input.positionWS));
                float3 H = normalize(V+L);//半角向量
            
                float HV = dot(H,V);
                float NV = dot(N,V);
                float NL = dot(N,L);
                float NH = dot(N,H);
                float TL = dot(T,L);
                float TH = dot(T,H);
                float NL01 = NL * 0.5 + 0.5;

                //Diffuse
                float RampOffsetMask = lightMap.r*2-1;     //Rampofsset,控制感光
                float ShadowAO = lightMap.g > 0.001;        //控制常暗区域
                float SpecularMask = lightMap.b;            //高光mask
                float3 BrightSide = baseMap * _BrightIntensity;
                float3 DarkSide = baseMap * _DarkIntensity;
                float Threshold = step(_LightThreshold, NL01 + _RampOffset + RampOffsetMask) * ShadowAO;
                float3 diffuse = lerp(DarkSide, BrightSide, Threshold);

                //TBN矩阵:将世界坐标转到Tangent坐标，（是正交矩阵，逆等于其转置）
                float3x3 TBN = float3x3(T, B, N);
                //将NormalMap 从Tangent坐标转到世界坐标
                N = normalize(mul(normalMap, TBN));  // N = normalize(mul(inverse(TBN), NormalMap));

                //PBR高光
                float3 F0 = lerp(0.04, baseMap, _Metallic);
                float3 specular = Specular_GGX(N, L, H, V, _Roughness, F0) * SpecularMask * _SpecularIntensity;
                
                finalColor.xyz = diffuse  + specular;
                finalColor.a = baseMap.a;
                
                //自发光
                #ifdef _RIM_ON
                    half rimStep = step(NV, _RimWidth);
                    #ifdef _RIMONLYDARK
                        rimStep = lerp(rimStep, 0, Threshold);
                    #endif
                        float3 rim = rimStep * _RimIntensity * baseMap.xyz;
                        finalColor.xyz += rim;
                #endif

                
                
                
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

            #include "../../comm/toon_input.hlsl"
            

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
