Shader "URP/NPR/unlit"
{
    Properties
    {
        _BaseMap ("BaseMap", 2D) = "white" {}
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv           : TEXCOORD0;
                float4 positionCS   : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _BaseMap_ST;
            CBUFFER_END
            TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionCS = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseMap);;
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                float4 finalColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                clip(0.1 - finalColor.r);
                return finalColor;
            }
            ENDHLSL
        }
    }
}
