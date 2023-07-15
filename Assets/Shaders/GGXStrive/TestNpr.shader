Shader "NPR/TestNpr"
{
    Properties
    {
        
        
        _DarkColor("DarkColor", Color) = (0,0,0,1.0)
        _LightColor("LightColor", Color) = (1.0,1.0,1.0,1.0)
        _LightThreshold("LightThreshold", Range(0,1)) = 0.3
        _SpecularExp("SpecularExp", float) = 64
        _SpecularIntensity("SpecularIntensity", float) = 2
        _RimExp("RimExp", float) = 64
        _RimWidth("RimWidth", Range(0,1)) = 0.3
        _RimIntensity("RimIntensity", float) = 2
        _ViewLightExp("ViewLightExp", float) = 64
        _ViewLightWidth("ViewLightWidth", Range(0,1)) = 0.3
        _ViewLightIntensity("ViewLightIntensity", float) = 2
        _RampTex("RampTex",2D) = "white"{}
        [Toggle(USETANGENT)] _UseTangent("使用切线", float) = 0
        _OutlineColor("OutlineColor", Color) = (1.0,0.0,0.0,1.0)
        _OutlineWidth("OutlineWidth", float) = 2
        _OutlineMaxDis("OutlineMaxDis", float) = 50
        
    }
    
    SubShader
    {
        Tags{"RenderType" = "Opaque"}
        LOD 100
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 tangent :TANGENT;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION; // 必须命名为pos ，因为 TRANSFER_VERTEX_TO_FRAGMENT 是这么命名的，为了正确地获取到Shadow
                float2 uv : TEXCOORD0;
                float3 tangent : TEXCOORD1;
                float3 bitangent : TEXCOORD2;
                float3 normal : TEXCOORD3;
                float3 positionWS : TEXCOORD4;
                float3 positionOS : TEXCOORD5;
                float2 uv2 : TEXCOORD6;
            };

            float4 _DarkColor;
            float4 _LightColor;
            float _LightThreshold;
            float _SpecularExp;
            float _SpecularIntensity;
            float _RimExp;
            float _RimWidth;
            float _RimIntensity;
            float _ViewLightExp;
            float _ViewLightIntensity;
            float _ViewLightWidth;
            sampler2D _RampTex;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.positionOS);
                o.uv = v.uv;
                o.uv2 = v.uv2;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.positionWS = mul(unity_ObjectToWorld, v.positionOS);
                o.positionOS = v.positionOS.xyz;
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.bitangent = cross(o.normal, o.tangent) * v.tangent.w;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.normal);
                float3 L = normalize(UnityWorldSpaceLightDir(i.positionWS));
                float3 V = normalize(UnityWorldSpaceViewDir(i.positionWS));
                // float NL = dot(N, L);
                // float NL01 = NL * 0.5 + 0.5;
                // //float shreshold = step(_LightThreshold, NL01);
                // float3 ramp = tex2D(_RampTex, NL01);
                // float3 diffuseColor = lerp(_DarkColor, _LightColor, ramp);
                // float3 diffuseColor1 = diffuseColor * ramp;
                // return float4(diffuseColor1, 1.0);

                // float3 H = normalize(L + V);
                // float NH = dot(N, H);
                // //float BlinPhong = pow(NH,_SpecularExp)*_SpecularIntensity;
                // float stepSpecular = step(1 - _SpecularExp * 0.01, NH) * _SpecularIntensity;
                // return stepSpecular;

                // float NV = dot(N, V);
                // //float3 Rim = pow(1-NV, _RimExp) * _RimIntensity;
                // //float3 Rim = step(1-_RimWidth, 1-NV) * _RimIntensity;
                // float3 Rim = step(NV, _RimWidth)* _RimIntensity;
                // return float4(Rim, 1.0);

                //float NV = dot(N, V);
                //float3 viewLight = pow(NV, _ViewLightExp) * _ViewLightIntensity;
                //float3 viewLight = step(_ViewLightWidth * 0.1,  NV) * _ViewLightIntensity;
                //float3 viewLight = step(1 - _ViewLightWidth * 0.1,  NV) * _ViewLightIntensity;
                //return float4(viewLight, 1.0);
                
                return float4(1.0, 1.0, 1.0, 1.0);
            }
            ENDCG
        }  
        
        Pass
        {
            cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 positionOS : POSITION;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            float _OutlineWidth;
            float4 _OutlineColor;
            float _UseTangent;
            float _OutlineMaxDis;

            
            v2f vert (appdata v)
            {
                v2f o;
                if(_UseTangent)
                {
                    o.pos = UnityObjectToClipPos(v.positionOS);
                    float3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.tangent.xyz));
                    float3 clipNormal = normalize(TransformViewToProjection(viewNormal.xyz));
                    
                    float aspect = abs(_ScreenParams.y / _ScreenParams.x);//求得屏幕宽高比
                    clipNormal.xy *= aspect;//求得屏幕宽高比
                    
                    o.pos.xy += (clipNormal  * o.pos.w*  _OutlineWidth * 0.01);
                }
                else
                {
                    o.pos = UnityObjectToClipPos(v.positionOS + v.normal.xyz * _OutlineWidth *0.01);
                }
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }     
    }

}