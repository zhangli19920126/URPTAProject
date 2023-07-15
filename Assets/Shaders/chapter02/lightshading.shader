// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "lightshading"
{
	Properties
	{
		_CheapSSSShift("CheapSSSShift", Range( 0 , 4)) = 1
		_CheapSSSExp("CheapSSSExp", Range( 0 , 5)) = 1
		_CheapSSSScale("CheapSSSScale", Range( 0 , 5)) = 1
		_SpecularExp1("SpecularExp", Range( 0 , 128)) = 65.12941
		_SpecularScale1("SpecularScale", Range( 0 , 10)) = 4.647059
		_TextureSample0("Texture Sample 0", 2D) = "white" {}

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			//This is a late directive
			
			uniform float _CheapSSSShift;
			uniform float _CheapSSSExp;
			uniform float _CheapSSSScale;
			uniform sampler2D _TextureSample0;
			uniform float _SpecularExp1;
			uniform float _SpecularScale1;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord1.xyz = ase_worldNormal;
				
				o.ase_texcoord2.xy = v.ase_texcoord1.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float3 ase_worldNormal = i.ase_texcoord1.xyz;
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float3 WN12 = normalizedWorldNormal;
				float3 worldSpaceLightDir = UnityWorldSpaceLightDir(WorldPosition);
				float3 WL11 = worldSpaceLightDir;
				float3 normalizeResult76 = normalize( ( ( WN12 * _CheapSSSShift ) + WL11 ) );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 WV14 = ase_worldViewDir;
				float dotResult78 = dot( -normalizeResult76 , WV14 );
				float CheapSSS92 = ( pow( dotResult78 , _CheapSSSExp ) * _CheapSSSScale );
				float dotResult25 = dot( WN12 , WL11 );
				float HalfLambert31 = pow( ( ( dotResult25 * 0.5 ) + 0.5 ) , 2.0 );
				float2 texCoord127 = i.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float3 normalizeResult110 = normalize( ( WL11 + WV14 ) );
				float dotResult111 = dot( normalizeResult110 , WN12 );
				float BlinPhongSpeclular116 = ( pow( dotResult111 , _SpecularExp1 ) * _SpecularScale1 );
				
				
				finalColor = ( ( ( max( CheapSSS92 , 0.0 ) + max( HalfLambert31 , 0.0 ) ) * tex2D( _TextureSample0, texCoord127 ) ) + BlinPhongSpeclular116 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
1972;83;1261;765;-203.7567;-560.1169;1.3;True;False
Node;AmplifyShaderEditor.WorldNormalVector;4;-1204.598,-1037.653;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;2;-1212.625,-1190.215;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-977.3797,-1045.747;Inherit;False;WN;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;85;-1225.573,1881.646;Inherit;False;1600.917;471.3977;Cheapsss;13;71;73;74;72;75;76;77;79;82;78;84;91;92;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-962.6,-1196.008;Inherit;False;WL;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1175.573,2025.681;Inherit;False;Property;_CheapSSSShift;CheapSSSShift;5;0;Create;True;0;0;0;False;0;False;1;1;0;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-1131.497,1931.646;Inherit;False;12;WN;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-1128.573,2175.681;Inherit;False;11;WL;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-886.5715,1951.682;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;69;-1231.084,-2.08943;Inherit;False;1115.124;421.4599;HalfLambert;9;24;25;28;26;30;27;29;23;31;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;24;-1181.063,132.0962;Inherit;False;11;WL;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-1181.084,47.91058;Inherit;False;12;WN;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;13;-1200.703,-873.8485;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-732.0482,1950.772;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1026.874,299.1087;Inherit;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;25;-991.1089,92.31959;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;76;-591.7589,1957.079;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-970.6028,-873.8488;Inherit;False;WV;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-853.5606,114.1135;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;117;559.0218,207.0049;Inherit;False;1384.049;442.008;BlinPhongSpecular;10;106;108;109;112;110;114;111;115;113;116;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NegateNode;77;-432.4577,1962.113;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;79;-525.9979,2043.311;Inherit;False;14;WV;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-337.8269,2224.415;Inherit;False;Property;_CheapSSSScale;CheapSSSScale;7;0;Create;True;0;0;0;False;0;False;1;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-366.1236,2120.612;Inherit;False;Property;_CheapSSSExp;CheapSSSExp;6;0;Create;True;0;0;0;False;0;False;1;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;78;-286.1664,1968.62;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;609.0218,257.005;Inherit;False;11;WL;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-716.8737,125.1086;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;615.8779,366.5757;Inherit;False;14;WV;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-689.9853,303.3706;Inherit;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;109;967.2001,277.4055;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;91;-49.17439,2012.077;Inherit;False;PowScale;-1;;1;446e59e9daa8c9c4e9377329946b6452;0;3;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;29;-570.7313,213.811;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;904.4614,385.903;Inherit;False;12;WN;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;110;1131.455,290.4436;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-56.39125,2004.861;Inherit;False;CheapSSS;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-339.9604,234.4758;Inherit;False;HalfLambert;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;853.7569,872.1171;Inherit;False;31;HalfLambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;111;1342.493,299.1389;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;1107.635,455.7546;Inherit;False;Property;_SpecularExp1;SpecularExp;9;0;Create;True;0;0;0;False;0;False;65.12941;0;0;128;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;1252.271,557.5782;Inherit;False;Property;_SpecularScale1;SpecularScale;11;0;Create;True;0;0;0;False;0;False;4.647059;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;129;855.0569,786.3165;Inherit;False;92;CheapSSS;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;131;1043.556,762.9169;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;132;1050.056,866.9166;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;113;1526.048,310.0371;Inherit;False;PowScale;-1;;3;446e59e9daa8c9c4e9377329946b6452;0;3;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;127;669.1571,977.4174;Inherit;False;1;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;130;1224.257,809.717;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;116;1732.172,311.3188;Inherit;False;BlinPhongSpeclular;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;125;894.0569,980.0167;Inherit;True;Property;_TextureSample0;Texture Sample 0;12;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;68;-1229.95,784.0652;Inherit;False;913.2444;417.1978;二分色light;8;45;43;41;42;46;47;40;48;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;70;-1228.272,-285.9145;Inherit;False;604.8878;250.1855;Lambert;5;6;16;15;22;122;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;67;-1230.517,439.2279;Inherit;False;1119.505;328.433;WarpLight;8;36;33;35;38;39;37;34;49;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;66;-1226.371,1212.344;Inherit;False;1453.542;632.4136;BandedLight;14;63;65;62;61;64;60;57;56;58;54;52;53;50;51;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;126;1251.557,931.9172;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;982.9963,1326.196;Inherit;False;116;BlinPhongSpeclular;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;105;113.3714,-319.7919;Inherit;False;905.5212;452.7855;PhongSpecular;7;97;98;99;100;101;102;104;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;16;-1220.251,-149.729;Inherit;False;11;WL;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;52;-986.3968,1306.753;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-511.2681,1317.514;Inherit;False;2;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;17;-1201.258,-702.6152;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;40;-1179.95,834.0652;Inherit;False;12;WN;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-1180.517,609.8484;Inherit;False;Property;_WarpValue;WarpValue;0;0;Create;True;0;0;0;False;0;False;0.48;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-807.384,-216.2288;Inherit;False;Lambert;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-852.4277,900.268;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-687.7295,651.6609;Inherit;False;Constant;_Float3;Float 3;0;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;6;-1054.297,-214.5055;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-690.7161,523.2371;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;-1219.272,-241.9145;Inherit;False;12;WN;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;120;1255.246,1138.325;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-848.8485,1328.547;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;60;-358.756,1322.167;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-1179.93,918.2505;Inherit;False;11;WL;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;102;233.2848,16.99344;Inherit;False;Property;_SpecularScale;SpecularScale;10;0;Create;True;0;0;0;False;0;False;4.647059;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;104;794.8924,-146.9427;Inherit;False;PhongSpecular;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;64;-354.1502,1626.883;Inherit;False;Property;_Color2;Color2;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;48;-738.6242,1065.003;Inherit;False;Property;_Float4;Float 4;1;0;Create;True;0;0;0;False;0;False;0.2352942;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;99;429.2281,-208.5912;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;42;-989.9759,878.4741;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;61;-238.7558,1315.167;Inherit;False;2;0;FLOAT;0;False;1;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;47;-468.7066,888.9708;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;62;-101.1525,1341.124;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;118;680.3438,857.9824;Inherit;False;22;Lambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-1176.371,1262.344;Inherit;False;12;WN;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;101;228.9848,-66.10672;Inherit;False;Property;_SpecularExp;SpecularExp;8;0;Create;True;0;0;0;False;0;False;65.12941;0;0;128;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-665.2194,1318.419;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-1124.532,489.2279;Inherit;False;22;Lambert;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1025.741,1085.263;Inherit;False;Constant;_Float2;Float 0;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-623.0264,-658.4136;Inherit;False;WL_R;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;37;-883.3516,651.6609;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;20;-1195.546,-541.2305;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-335.0123,535.0151;Inherit;False;WarpLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;164.5259,-149.5506;Inherit;False;14;WV;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;18;-949.8985,-678.3362;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-877.3783,517.2639;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;122;-941.2292,-205.689;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;163.3715,-269.7921;Inherit;False;21;WL_R;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;63;-354.1501,1444.871;Inherit;False;Property;_Color1;Color1;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ReflectOpNode;19;-817.9864,-673.1428;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-1022.162,1513.542;Inherit;False;Constant;_Float5;Float 0;0;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-668.7985,890.1391;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;100;584.4705,-192.952;Inherit;False;PowScale;-1;;2;446e59e9daa8c9c4e9377329946b6452;0;3;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;-1176.351,1346.53;Inherit;False;11;WL;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;38;-532.4263,524.7304;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;20.79574,1563.179;Inherit;False;BandedLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IntNode;58;-664.2365,1494.156;Inherit;False;Property;_BandedValue;BandedValue;2;0;Create;True;0;0;0;False;0;False;4;0;True;0;1;INT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1400.748,1141.502;Float;False;True;-1;2;ASEMaterialInspector;100;1;lightshading;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;False;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;1;True;False;;False;0
WireConnection;12;0;4;0
WireConnection;11;0;2;0
WireConnection;72;0;71;0
WireConnection;72;1;73;0
WireConnection;75;0;72;0
WireConnection;75;1;74;0
WireConnection;25;0;23;0
WireConnection;25;1;24;0
WireConnection;76;0;75;0
WireConnection;14;0;13;0
WireConnection;26;0;25;0
WireConnection;26;1;27;0
WireConnection;77;0;76;0
WireConnection;78;0;77;0
WireConnection;78;1;79;0
WireConnection;28;0;26;0
WireConnection;28;1;27;0
WireConnection;109;0;106;0
WireConnection;109;1;108;0
WireConnection;91;8;78;0
WireConnection;91;9;82;0
WireConnection;91;10;84;0
WireConnection;29;0;28;0
WireConnection;29;1;30;0
WireConnection;110;0;109;0
WireConnection;92;0;91;0
WireConnection;31;0;29;0
WireConnection;111;0;110;0
WireConnection;111;1;112;0
WireConnection;131;0;129;0
WireConnection;132;0;128;0
WireConnection;113;8;111;0
WireConnection;113;9;114;0
WireConnection;113;10;115;0
WireConnection;130;0;131;0
WireConnection;130;1;132;0
WireConnection;116;0;113;0
WireConnection;125;1;127;0
WireConnection;126;0;130;0
WireConnection;126;1;125;0
WireConnection;52;0;51;0
WireConnection;52;1;50;0
WireConnection;57;0;56;0
WireConnection;57;1;58;0
WireConnection;22;0;122;0
WireConnection;43;0;42;0
WireConnection;43;1;41;0
WireConnection;6;0;15;0
WireConnection;6;1;16;0
WireConnection;36;0;34;0
WireConnection;36;1;37;0
WireConnection;120;0;126;0
WireConnection;120;1;119;0
WireConnection;54;0;52;0
WireConnection;54;1;53;0
WireConnection;60;0;57;0
WireConnection;104;0;100;0
WireConnection;99;0;97;0
WireConnection;99;1;98;0
WireConnection;42;0;40;0
WireConnection;42;1;45;0
WireConnection;61;0;60;0
WireConnection;61;1;58;0
WireConnection;47;0;48;0
WireConnection;47;1;46;0
WireConnection;62;0;63;0
WireConnection;62;1;64;0
WireConnection;62;2;61;0
WireConnection;56;0;54;0
WireConnection;56;1;53;0
WireConnection;21;0;19;0
WireConnection;37;0;35;0
WireConnection;49;0;38;0
WireConnection;18;0;17;0
WireConnection;34;0;33;0
WireConnection;34;1;35;0
WireConnection;122;0;6;0
WireConnection;19;0;18;0
WireConnection;19;1;20;0
WireConnection;46;0;43;0
WireConnection;46;1;41;0
WireConnection;100;8;99;0
WireConnection;100;9;101;0
WireConnection;100;10;102;0
WireConnection;38;0;36;0
WireConnection;38;1;39;0
WireConnection;65;0;62;0
WireConnection;0;0;120;0
ASEEND*/
//CHKSM=79496D2FFC6A0350010B7F68DFE84E5B4FBD3DB7