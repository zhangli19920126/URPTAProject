Shader "URP/NPR/strivehead"
{
    Properties
    {
        [MainTexture]_BaseMap ("BaseMap", 2D) = "white" {}
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

            #include "../comm/npr_input.hlsl"
            

            NPRVaryings vert (NPRAttributes v)
            {
                NPRVaryings o = NPRForwardPassVertex(v);
                
                return o;
            }

            half4 frag (NPRVaryings i) : SV_Target
            {
                return SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
            }
            ENDHLSL
        }
    }
}
