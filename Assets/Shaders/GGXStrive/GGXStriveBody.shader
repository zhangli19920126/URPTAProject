Shader "NPR/GGXStriveBody"
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
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }

        Pass
        {
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag

            #define Black   float4(0,0,0,1)
            #define White   float4(1,1,1,1)
            #define Red     float4(1,0,0,1)
            #define Green   float4(0,1,0,1)
            #define Blue    float4(0,0,1,1)
            #define Yellow  float4(1,1,0,1)
            #define Cyan    float4(0,0,1,1)
            #define Fuck    float4(0.6,0.2,0.1,1)

            sampler2D _BaseMap;
            sampler2D _LightMap;
            sampler2D _LineMap;
            sampler2D _MixMap;
            sampler2D _ShadowMap;
            sampler2D _DecalMap;
            
            float _LightThreshold;
            float _LineIntensity;
            float _DarkIntensity;
            float _SpecularIntensity;
            float _SpecularPowerValue;
            float _MetallicStepSpecularIntensity;
            float _MetallicStepSpecularWidth;
            float _LeatherStepSpecularWidth;
            float _LeatherStepSpecularIntensity;
            float _CommonStepSpecularWidth;
            float _CommonStepSpecularIntensity;
            float _RimWidth;
            float _RimIntensity;

            struct appdata
            {
                float4 position     :   POSITION;
                float2 uv           :   TEXCOORD0;
                float2 uv2          :   TEXCOORD1;
                float4 tangent      :   TANGENT;
                float3 normal       :   NORMAL;
                float4 colorVrt     :   Color;
            };

            struct v2f
            {
                float4 pos          : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float3 tangent      : TEXCOORD1;
                float3 normal       : TEXCOORD2; 
                float3 positionWS   : TEXCOORD3;
                float3 positionOS   : TEXCOORD4;
                float3 normalOS     : TEXCOORD5;
                float4 colorVrt     : TEXCOORD6;
                float2 uv2          : TEXCOORD7;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos           = UnityObjectToClipPos(v.position);
                o.uv            = v.uv;
                o.uv2           = v.uv2;
                o.normal        = UnityObjectToWorldNormal(v.normal);
                o.positionWS    = UnityObjectToWorldDir(v.position);
                o.positionOS    = v.position.xyz;
                o.tangent       = UnityObjectToWorldDir(v.tangent);
                o.normalOS      = v.normal;
                o.colorVrt      = v.colorVrt;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 finalColor   = 1;
                
                //Variable
                float3 T = normalize(i.tangent);
                float3 N = normalize(i.tangent);
                float3 B = normalize(cross(N,T));
                float3 L = normalize(UnityWorldSpaceLightDir(i.positionWS.xyz));
                float3 V = normalize(UnityWorldSpaceViewDir(i.positionWS.xyz));
                float3 H = normalize(V+L);//半角向量
                float2 uv = i.uv;
                float2 uv2 = i.uv2;

                //useful dot
                float HV = dot(H,V);
                float NV = dot(N,V);
                float NL = dot(N,L);
                float NH = dot(N,H);
                float TL = dot(T,L);
                float TH = dot(T,H);

                //all maps
                float4 BaseMap      = tex2D(_BaseMap,uv);
                float4 LightMap     = tex2D(_LightMap,uv);
                float4 LineMap      = tex2D(_LineMap,uv);
                float4 MixMap       = tex2D(_MixMap,uv);
                float4 ShadowMap    = tex2D(_ShadowMap,uv);
                float4 DecalMap     = tex2D(_DecalMap,uv);

                float4 vertexColor              = i.colorVrt;
                float shadowAOMask              = vertexColor.r > 0.5;  //AO 常暗部分
                float layerMask                 = LightMap.r;           //材质类型
                float rampOffsetMask            = LightMap.g *2-1;      //Ramp偏移值  //值域重新映射 [0,1]-> [-1,1]
                float specularIntensityMask     = LightMap.b;           //高光强度mask
                float innerLineMask             = LightMap.a;           //内勾线Mask

                //----------------- diffuse ------------------
                float NL01 = NL*0.5 + 0.5;
                float threshold = step(_LightThreshold, (NL01 + rampOffsetMask) * shadowAOMask);
                BaseMap*= innerLineMask; //内勾线
                BaseMap = lerp(BaseMap,BaseMap*LineMap,_LineIntensity); //旧损线
                float3 brightSide = BaseMap;//亮部色
                float3 darkSide = lerp(ShadowMap*BaseMap, BaseMap, _DarkIntensity); //暗部色 = ShadowMap*BaseMap
                float3 diffuse = lerp( darkSide,brightSide,threshold);

                //---------------- 边缘光 --------------------
                //将平滑后的法线转到 视角空间下
                float3 N_ViewSpaceS = mul((float3x3)UNITY_MATRIX_V, N);
                float3 rim = step(1-_RimWidth, abs(N_ViewSpaceS.x)) * _RimIntensity * BaseMap;
                //float3 rim = step(NV, _RimWidth) * _RimIntensity * BaseMap;
                rim = lerp(rim, 0, threshold);

                //----------------- specular ------------------
                float3 specular = pow(saturate(NH),_SpecularPowerValue)*_SpecularIntensity * specularIntensityMask*BaseMap;//传统高光
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
                    float3 metallicStepSpecular = step(abs(N_ViewSpaceS.x) , _MetallicStepSpecularWidth)*_MetallicStepSpecularIntensity*BaseMap; //裁边视角光(模拟反射,ViewSpace)
                    metallicStepSpecular = max(0,metallicStepSpecular);
                    specular += metallicStepSpecular;
                    //return 0;
                    //return float4(specular,1);
                }

                finalColor = diffuse + specular + rim;
                //finalColor = 1;
                return float4(finalColor,1);
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
                 
                 // o.pos = UnityObjectToClipPos(v.position);
                 // float3 viewNormalNew = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.tangent.xyz));
                 // float2 clipNormalNew = normalize(mul((float3x3)UNITY_MATRIX_P, viewNormalNew));
                 // float aspect = abs(_ScreenParams.y / _ScreenParams.x);//求得屏幕宽高比
                 // clipNormalNew.xy *= aspect;//求得屏幕宽高比
                 // o.pos.xy += (clipNormalNew  * o.pos.w * _OutLineWidth * v.color.a * 0.001);
                 
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
