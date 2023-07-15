Shader "NPR/GGXStriveHead"
{
    Properties
    {
        _BaseMap    ("_BaseMap", 2D)    = "white" {}
        _LightMap   ("_LightMap", 2D)   = "white" {}
        _LineMap    ("_LineMap", 2D)    = "white" {}
        _MixMap     ("_MixMap", 2D)     = "black" {}
        _ShadowMap  ("_ShadowMap", 2D)  = "white" {}
        
        [Space(20)]
        _LightThresholdHair("头发LightThreshold",Range(-2,2))=1
        _RampOffset("RampOffset",Range(-2,2)) =0
        _DarkIntensity("暗部强度",Range(0,1)) = 0
        _LightThresholdFace("脸部LightThreshold",Range(-2,2))=1

        [Space(20)]
        [KeywordEnum(Tex,Color)] FaceShadowMode("脸部暗部模式",Float) = 0
        _FaceShadowColor("脸部暗部颜色",Color) = (0.5,0.5,0.5,0.5)
        
        [Space(20)]
        _HairSpecularBrightIntensity("头发高光亮部强度",Float) =1
        _HairSpecularDarkIntensity("头发高光暗部强度",Float) =0.1
        
        [Space(20)]
        _LineIntensity("损旧线条强度",Range(0,1)) = 0
        
        [Space(20)]
        _RimWidth("边缘光宽度",Float) =0.5
        _RimIntensity("边缘光强度",Float) =0.3
        
        [Space(20)]
        _OutLineWidth("描边粗细",Float) =1
        _OutlineColor ("描边颜色",Color) = (0,0,0,0)
        
        [Space(20)]
        _LumIntensity("Lum Intenisty",Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature FACESHADOWMODE_TEX FACESHADOWMODE_COLOR  

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex           : POSITION;
                float2 uv               : TEXCOORD0;
                float2 uv2              : TEXCOORD1;
                float4 tangent          :TANGENT;
                float3 normal           : NORMAL;
                float4 vertexColor      : Color;
            };

            struct v2f
            {
                float4 pos              : SV_POSITION;
                float2 uv               : TEXCOORD0;
                float3 tangent          : TEXCOORD1;
                float3 bitangent        : TEXCOORD2; 
                float3 normal           : TEXCOORD3; 
                float3 worldPosition    : TEXCOORD4;
                float3 localPosition    : TEXCOORD5;
                float3 localNormal      : TEXCOORD6;
                float4 vertexColor      : TEXCOORD7;
                float2 uv2              : TEXCOORD10;

            };

            sampler2D _BaseMap;
            sampler2D _LightMap;
            sampler2D _LineMap;
            sampler2D _MixMap;
            sampler2D _ShadowMap;
            
            float4 _FaceShadowColor;
            float4 _SpecularColor;
            float _RampOffset;
            float _LightThresholdFace;
            float _LightThresholdHair;
            float _LineIntensity;
            float _DarkIntensity;
            float _HairSpecularBrightIntensity;
            float _HairSpecularDarkIntensity;
            float _RimWidth,_RimIntensity;
            float _LumIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv2 = v.uv2;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPosition = mul(unity_ObjectToWorld,v.vertex);
                o.localPosition = v.vertex.xyz;
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.bitangent = cross(o.normal,o.tangent) * v.tangent.w;
                o.localNormal = v.normal;
                o.vertexColor = v.vertexColor;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                
                //Variable
                float3 T = normalize(i.tangent);
                float3 N = normalize(i.tangent);
                float3 B = normalize(cross(N,T));
                float3 L = normalize(UnityWorldSpaceLightDir(i.worldPosition.xyz));
                float3 V = normalize(UnityWorldSpaceViewDir(i.worldPosition.xyz));
                float3 H = normalize(V+L);
                float2 uv = i.uv;
                //uv.y = 1-uv.y;  //uv颠倒了,如果在 Csv2Obj阶段已经反转了，这里就不需要再转了
                float2 uv2 = i.uv2;

                // return float4(uv2,0,0);
                float4 VertexColor = i.vertexColor;
                // return VertexColor.xyzz;
                float HV = dot(H,V);
                float NV = dot(N,V);
                float NL = dot(N,L);
                float NH = dot(N,H);

                float TL = dot(T,L);
                float TH = dot(T,H);
                
                float3 FinalColor   = 0;
                float4 BaseMap      = tex2D(_BaseMap,uv);
                float4 LightMap     = tex2D(_LightMap,uv);
                float4 LineMap      = tex2D(_LineMap,uv);
                float4 MixMap       = tex2D(_MixMap,uv);
                float4 ShadowMap    = tex2D(_ShadowMap,uv);

                float specularLayerMask         = LightMap.r;       //高光类型
                float rampOffsetMask            = LightMap.g*2-1;   //Ramp偏移值
                float specularIntensityMask     = LightMap.b;       //高光强度mask
                float innerLineMask             = LightMap.a;       //内勾线Mask
                float shadowAOMask              = VertexColor.r;    //AO 常暗部分
                                                 // VertexColor.g;  //用来区分身体的部位, 比如 脸部=88
                                                 // VertexColor.b;  //渲染无用
                float outlineIntensity          = VertexColor.a;    //描边粗细

                float3 finalColor = 1;

                /*==========================Diffuse ==========================*/
                if (VertexColor.g<0.9) //face， 只有漫反射
                {
                    NL = dot(T.xz,L.xz);
                    // NL = dot(T,L);
                    float NL01 = 0.5*NL+0.5;
                    float Threshold = step(_LightThresholdFace,(NL01 + _RampOffset)*shadowAOMask);
                    float3 BrightSide_Face = BaseMap;
                    float3 DarktSide_Face = 0;
                    #ifdef FACESHADOWMODE_TEX
                        DarktSide_Face =  ShadowMap*BaseMap;
                    #endif
                    
                    #ifdef FACESHADOWMODE_COLOR
                        DarktSide_Face =  BaseMap*_FaceShadowColor;
                    #endif

                    float3 DarkSide = lerp(DarktSide_Face ,BrightSide_Face,_DarkIntensity);
                    float3 BrightSide= BaseMap;
                    float3 Diffuse = lerp( DarkSide,BrightSide,Threshold);
                    
                    finalColor =  Diffuse;
                }
                else
                {
                    float NL01 = NL * 0.5 + 0.5;
                    float threshold = step(_LightThresholdHair, NL01 + _RampOffset + rampOffsetMask) * shadowAOMask;
                    BaseMap *= innerLineMask;
                    BaseMap = lerp(BaseMap, BaseMap*LineMap, _LineIntensity);
                    float3 Diffuse = lerp( lerp(ShadowMap*BaseMap,BaseMap,_DarkIntensity),BaseMap,threshold);

                    //高光
                    float3 specular = 0;
                    specular = specularIntensityMask*BaseMap*lerp(_HairSpecularDarkIntensity,_HairSpecularBrightIntensity,threshold);

                    //边缘光
                    float3 N_VS = mul((float3x3)UNITY_MATRIX_V, T);
                    float3 rim = step(1-_RimWidth,abs(N_VS.x))*_RimIntensity*BaseMap;
                    rim = lerp(rim,0,threshold);
                    rim = max(0,rim);

                    finalColor = Diffuse + specular + rim;
                }
                
                
                return float4(finalColor, 1)*_LumIntensity;
            }
            ENDCG
        }
        
        Pass
        {
            Name "OUTLINE"
            Cull Front
            
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 position : POSITION;
                float4 color : COLOR;
                float4 tangent :TANGENT;
            };

            float _OutLineWidth;
            float4 _OutLineColor;

            struct v2f
            {
                float4 pos : SV_POSITION; 
            };
            
             v2f vert(appdata v)
             {
                 v2f o;
                 v.position.xyz += v.tangent.xyz *_OutLineWidth*0.01*v.color.a; //用顶点色的alpha通道控制描边粗细
                 o.pos = UnityObjectToClipPos(v.position);
                 return o;
             }
            
            float4 frag(v2f i) : SV_Target
            {
                return _OutLineColor;
            }
            ENDCG
        }
    }
}
