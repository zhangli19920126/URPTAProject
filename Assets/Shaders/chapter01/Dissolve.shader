Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _Noise("Noise", 2D) = "white" {}
        [Slider]_BurnValue("BurnValue", Range(-1, 4)) = 0.5
        [Slider]_BurnWidth("BurnWidth", Range(0, 1)) = 0.5
        [Slider]_BurnNoise("BurnNoise", Range(10, 100)) = 50
        [Slider]_BurnOffset("BurnOffset", Range(0, 1)) = 0.5
        [HDR]_BurnColor("BurnColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 positionOS : TEXCOORD2;
                float4 positionCS : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Noise;
            float4 _Noise_ST;
            float _BurnValue;
            float _BurnWidth;
            float _BurnNoise;
            float _BurnOffset;
            float4 _BurnColor;

            inline float noise_randomValue (float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453); }
			inline float noise_interpolate (float a, float b, float t) { return (1.0-t)*a + (t*b); }
			inline float valueNoise (float2 uv)
			{
				float2 i = floor(uv);
				float2 f = frac( uv );
				f = f* f * (3.0 - 2.0 * f);
				uv = abs( frac(uv) - 0.5);
				float2 c0 = i + float2( 0.0, 0.0 );
				float2 c1 = i + float2( 1.0, 0.0 );
				float2 c2 = i + float2( 0.0, 1.0 );
				float2 c3 = i + float2( 1.0, 1.0 );
				float r0 = noise_randomValue( c0 );
				float r1 = noise_randomValue( c1 );
				float r2 = noise_randomValue( c2 );
				float r3 = noise_randomValue( c3 );
				float bottomOfGrid = noise_interpolate( r0, r1, f.x );
				float topOfGrid = noise_interpolate( r2, r3, f.x );
				float t = noise_interpolate( bottomOfGrid, topOfGrid, f.y );
				return t;
			}
			
			float SimpleNoise(float2 UV)
			{
				float t = 0.0;
				float freq = pow( 2.0, float( 0 ) );
				float amp = pow( 0.5, float( 3 - 0 ) );
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(1));
				amp = pow(0.5, float(3-1));
				t += valueNoise( UV/freq )*amp;
				freq = pow(2.0, float(2));
				amp = pow(0.5, float(3-2));
				t += valueNoise( UV/freq )*amp;
				return t;
			}
			

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = UnityObjectToClipPos(v.positionOS);
                o.positionWS = mul(unity_ObjectToWorld, v.positionOS);
                o.positionOS = v.positionOS.xyz;
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _Noise);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 baseCol = tex2D(_MainTex, i.uv.xy);
                //float noiseCol = tex2D(_Noise, i.uv.zw).r + 0.3;
            	float noise = SimpleNoise(i.uv.xy * _BurnNoise) + 0.2;
            	
            	
                float height = i.positionOS.y + _BurnOffset;
                float burn = noise * _BurnValue;
                float burn2 = burn + _BurnWidth * _BurnValue;
                float st = step(height , burn);
                float st2 = step(height , burn2);

                clip(height - burn);
                
                return lerp(baseCol, baseCol * _BurnColor, st2 -st);
            }
            ENDCG
        }
    }
}
