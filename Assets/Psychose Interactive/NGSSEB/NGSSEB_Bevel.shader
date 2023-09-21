﻿Shader "Hidden/NGSSEB_Bevel"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader
	{
		// No culling or depth
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }
		Blend Off
		/*
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#pragma multi_compile_local _ POISSON_32 POISSON_64 POISSON_128
			#include "UnityCG.cginc"

			uniform sampler2D _MainTex;
			uniform float4 _MainTex_TexelSize;
			uniform sampler2D_float _CameraDepthTexture;
			uniform float m_edge_thickness;

			static const float2 PoissonDisks[8] =
			{
					float2(-1, -1),
					float2(-1, 0),
					float2(-1, 1),
					float2(0, -1),
					float2(0, 1),
					float2(1, -1),
					float2(1, 0),
					float2(1, 1)
			};

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_LOD(_CameraDepthTexture, float4(UnityStereoTransformScreenSpaceTex(i.uv), 0, 0)).r);
				
				float depth_avg = depth;

				for (int j = 0; j < 8; j++)
					depth_avg += LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_LOD(_CameraDepthTexture, float4(UnityStereoTransformScreenSpaceTex(i.uv + PoissonDisks[j] / _ScreenParams.xy), 0, 0)).r);

				depth_avg /= 8;

				return lerp(0, 1, step(m_edge_thickness, length(depth - depth_avg)));
			}
			ENDCG
		}*/

		Pass
		{// 0 stencil mask

			Stencil
			{
				Ref 10
				ReadMask 10
				Comp Equal
			}

			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment frag

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;

			v2f vert(appdata_img v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.texcoord.xy;
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				return half4(tex2D(_MainTex, i.uv).rgb, 1.0);
			}
			ENDCG
		}

		Pass
		{
			Stencil
			{
				Ref 10
				ReadMask 10
				Comp NotEqual
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_local _ POISSON_32 POISSON_64 POISSON_128
			#include "UnityCG.cginc"

			uniform sampler2D NGSSEB_EdgeMask;
			uniform sampler2D_float _CameraDepthTexture;
			uniform sampler2D _MainTex, _NormalsCopy;
			//uniform sampler2D _CameraGBufferTexture2;

			uniform float m_edge_offset;
			uniform float m_edge_distance;
			uniform float m_bevel_radius;
			uniform float m_bevel_distance;
			uniform float m_edge_thickness;
			//uniform int m_bevel_samplers;

#if defined(POISSON_128)
			static const int Samplers_Count = 128;
			static const float2 PoissonDisks[128] =
			{
				float2 (-0.2367787, 0.4901892),
				float2 (-0.3067145, 0.6599227),
				float2 (-0.1616595, 0.7254592),
				float2 (-0.4227801, 0.3229555),
				float2 (-0.4746405, 0.4624885),
				float2 (-0.02666831, 0.4906617),
				float2 (-0.1461937, 0.3522153),
				float2 (-0.2836505, 0.3249041),
				float2 (-0.03740598, 0.6329193),
				float2 (-0.1292047, 0.1889183),
				float2 (0.06661285, 0.3683913),
				float2 (-0.2859527, 0.1483711),
				float2 (0.01433537, 0.2475814),
				float2 (-0.01132843, 0.7631852),
				float2 (-0.2184855, 0.8846649),
				float2 (-0.3903657, 0.7600643),
				float2 (-0.07552132, 0.9133397),
				float2 (0.1710439, 0.7008814),
				float2 (0.1391777, 0.5709726),
				float2 (0.07363454, 0.8635173),
				float2 (-0.4941275, 0.1842116),
				float2 (-0.5412169, 0.6853794),
				float2 (-0.425546, 0.5922924),
				float2 (-0.6466808, 0.03978668),
				float2 (-0.6634844, 0.2321819),
				float2 (-0.4938175, -0.001419672),
				float2 (-0.3278933, -0.01152995),
				float2 (-0.7977815, 0.2398731),
				float2 (-0.8286724, 0.3857125),
				float2 (-0.7988419, 0.05790134),
				float2 (-0.6623837, 0.3731333),
				float2 (0.08254691, 0.09132266),
				float2 (0.1745314, 0.2063142),
				float2 (-0.0703319, 0.01107812),
				float2 (0.2536064, 0.3460345),
				float2 (-0.6207574, 0.5073496),
				float2 (-0.7248882, 0.5964983),
				float2 (-0.6806865, 0.72211),
				float2 (0.3832989, 0.5220767),
				float2 (0.3028488, 0.6359207),
				float2 (-0.6465305, -0.1068089),
				float2 (-0.4692663, -0.2492552),
				float2 (-0.3643594, -0.1591648),
				float2 (0.4516504, 0.6501877),
				float2 (0.5113109, 0.4880795),
				float2 (0.5895482, 0.6321136),
				float2 (0.5106937, 0.3271424),
				float2 (0.6451618, 0.3510359),
				float2 (0.6413455, 0.4992366),
				float2 (0.3909793, 0.3858602),
				float2 (0.283926, 0.8730315),
				float2 (0.476542, 0.7805386),
				float2 (0.727109, 0.6244066),
				float2 (0.6144412, 0.181504),
				float2 (0.4096124, 0.1739766),
				float2 (0.278091, -0.02838729),
				float2 (0.2909363, 0.1169052),
				float2 (-0.3609014, -0.3968496),
				float2 (-0.5727078, -0.3509097),
				float2 (-0.2417752, -0.2238419),
				float2 (-0.5011169, -0.5000672),
				float2 (0.8973918, 0.3360424),
				float2 (0.752505, 0.2383271),
				float2 (0.6567625, 0.7472429),
				float2 (-0.9467769, 0.2731125),
				float2 (-0.9252222, 0.09196262),
				float2 (-0.4713456, 0.8770475),
				float2 (-0.3161662, -0.5501466),
				float2 (-0.5205767, -0.7258629),
				float2 (-0.6948451, -0.4750859),
				float2 (-0.3531139, -0.6912672),
				float2 (-0.6919448, -0.6388381),
				float2 (0.7677299, 0.4491784),
				float2 (-0.458206, -0.872004),
				float2 (-0.3055792, -0.850623),
				float2 (-0.8475943, 0.5245672),
				float2 (0.9406309, 0.1386568),
				float2 (0.7253717, 0.08629423),
				float2 (-0.9118658, -0.07326309),
				float2 (-0.202966, -0.7705109),
				float2 (-0.1247103, -0.5884792),
				float2 (-0.1998137, -0.08350364),
				float2 (-0.2088391, -0.4162863),
				float2 (-0.8804737, -0.1069524),
				float2 (-0.0820531, -0.3091766),
				float2 (-0.7659051, -0.1831385),
				float2 (-0.7991378, -0.3809945),
				float2 (-0.1684138, -0.9658166),
				float2 (-0.03333611, -0.8163373),
				float2 (-0.6914942, -0.2980516),
				float2 (-0.8284369, -0.5358804),
				float2 (0.2550101, 0.4957033),
				float2 (0.5583357, -0.04477769),
				float2 (0.4610983, 0.05115379),
				float2 (-0.02488372, -0.9829083),
				float2 (0.1322045, -0.09329918),
				float2 (-0.9220811, -0.2793948),
				float2 (0.8650895, 0.02036999),
				float2 (0.124429, -0.2666473),
				float2 (0.2596441, -0.2372703),
				float2 (0.7572334, -0.1326314),
				float2 (0.5060279, -0.180913),
				float2 (0.6361921, -0.2048395),
				float2 (0.8838742, -0.1960855),
				float2 (0.7770295, -0.3713599),
				float2 (0.4667997, -0.3812411),
				float2 (0.5975081, -0.3628165),
				float2 (-0.05966386, -0.4422135),
				float2 (0.09921371, -0.4335754),
				float2 (0.02576026, -0.6545462),
				float2 (0.1637208, -0.8230984),
				float2 (0.3726746, -0.1253497),
				float2 (0.1559616, -0.9565104),
				float2 (0.9600466, -0.07366105),
				float2 (0.2623834, -0.414741),
				float2 (0.1862826, -0.6195262),
				float2 (0.1383334, 0.9898438),
				float2 (0.4451495, -0.5591879),
				float2 (0.3375484, -0.6613742),
				float2 (0.3923327, -0.2581888),
				float2 (0.3842012, -0.8586627),
				float2 (0.5498597, -0.7814276),
				float2 (0.5922456, -0.6579062),
				float2 (0.923216, -0.3776534),
				float2 (0.7154181, -0.5230829),
				float2 (0.5640847, -0.4905176),
				float2 (0.7366304, -0.671463),
				float2 (0.8643044, -0.4947536)
			};
#elif defined(POISSON_64)
			static const int Samplers_Count = 64;
			static const float2 PoissonDisks[64] =
			{
				float2 (0.1187053, 0.7951565),
				float2 (0.1173675, 0.6087878),
				float2 (-0.09958518, 0.7248842),
				float2 (0.4259812, 0.6152718),
				float2 (0.3723574, 0.8892787),
				float2 (-0.02289676, 0.9972908),
				float2 (-0.08234791, 0.5048386),
				float2 (0.1821235, 0.9673787),
				float2 (-0.2137264, 0.9011746),
				float2 (0.3115066, 0.4205415),
				float2 (0.1216329, 0.383266),
				float2 (0.5948939, 0.7594361),
				float2 (0.7576465, 0.5336417),
				float2 (-0.521125, 0.7599803),
				float2 (-0.2923127, 0.6545699),
				float2 (0.6782473, 0.22385),
				float2 (-0.3077152, 0.4697627),
				float2 (0.4484913, 0.2619455),
				float2 (-0.5308799, 0.4998215),
				float2 (-0.7379634, 0.5304936),
				float2 (0.02613133, 0.1764302),
				float2 (-0.1461073, 0.3047384),
				float2 (-0.8451027, 0.3249073),
				float2 (-0.4507707, 0.2101997),
				float2 (-0.6137282, 0.3283674),
				float2 (-0.2385868, 0.08716244),
				float2 (0.3386548, 0.01528411),
				float2 (-0.04230833, -0.1494652),
				float2 (0.167115, -0.1098648),
				float2 (-0.525606, 0.01572019),
				float2 (-0.7966855, 0.1318727),
				float2 (0.5704287, 0.4778273),
				float2 (-0.9516637, 0.002725032),
				float2 (-0.7068223, -0.1572321),
				float2 (0.2173306, -0.3494083),
				float2 (0.06100426, -0.4492816),
				float2 (0.2333982, 0.2247189),
				float2 (0.07270987, -0.6396734),
				float2 (0.4670808, -0.2324669),
				float2 (0.3729528, -0.512625),
				float2 (0.5675077, -0.4054544),
				float2 (-0.3691984, -0.128435),
				float2 (0.8752473, 0.2256988),
				float2 (-0.2680127, -0.4684393),
				float2 (-0.1177551, -0.7205751),
				float2 (-0.1270121, -0.3105424),
				float2 (0.5595394, -0.06309237),
				float2 (-0.9299136, -0.1870008),
				float2 (0.974674, 0.03677348),
				float2 (0.7726735, -0.06944724),
				float2 (-0.4995361, -0.3663749),
				float2 (0.6474168, -0.2315787),
				float2 (0.1911449, -0.8858921),
				float2 (0.3671001, -0.7970535),
				float2 (-0.6970353, -0.4449432),
				float2 (-0.417599, -0.7189326),
				float2 (-0.5584748, -0.6026504),
				float2 (-0.02624448, -0.9141423),
				float2 (0.565636, -0.6585149),
				float2 (-0.874976, -0.3997879),
				float2 (0.9177843, -0.2110524),
				float2 (0.8156927, -0.3969557),
				float2 (-0.2833054, -0.8395444),
				float2 (0.799141, -0.5886372)
			};

#elif defined(POISSON_32)
			static const int Samplers_Count = 32;
			static const float2 PoissonDisks[32] =
			{
				float2 (0.4873902, -0.8569599),
				float2 (0.3463737, -0.3387939),
				float2 (0.6290055, -0.4735314),
				float2 (0.1855854, -0.8848142),
				float2 (0.7677917, 0.02691162),
				float2 (0.3009142, -0.6365873),
				float2 (0.4268422, -0.006137629),
				float2 (-0.06682982, -0.7833805),
				float2 (0.0347263, -0.3994124),
				float2 (0.4494694, 0.5206614),
				float2 (0.219377, 0.2438844),
				float2 (0.1285765, -0.1215554),
				float2 (0.8907049, 0.4334931),
				float2 (0.2556469, 0.766552),
				float2 (-0.03692406, 0.3629236),
				float2 (0.6651103, 0.7286811),
				float2 (-0.429309, -0.2282262),
				float2 (-0.2730969, -0.4683513),
				float2 (-0.2755986, 0.7327913),
				float2 (-0.3329705, 0.1754638),
				float2 (-0.1731326, -0.1087716),
				float2 (0.9212226, -0.3716638),
				float2 (-0.5388235, 0.4603968),
				float2 (-0.6307321, 0.7615924),
				float2 (-0.7709175, -0.08894937),
				float2 (-0.7205971, -0.3609493),
				float2 (-0.5386202, -0.5847159),
				float2 (-0.6520834, 0.1785284),
				float2 (-0.9310582, 0.2040343),
				float2 (-0.828178, 0.5559599),
				float2 (0.6297836, 0.2946501),
				float2 (-0.05836084, 0.9006807)
			};
#else
			static const int Samplers_Count = 16;
			static const float2 PoissonDisks[16] =
			{
				float2(0.1232981, -0.03923375),
				float2(-0.5625377, -0.3602428),
				float2(0.6403719, 0.06821123),
				float2(0.2813387, -0.5881588),
				float2(-0.5731218, 0.2700572),
				float2(0.2033166, 0.4197739),
				float2(0.8467958, -0.3545584),
				float2(-0.4230451, -0.797441),
				float2(0.7190253, 0.5693575),
				float2(0.03815468, -0.9914171),
				float2(-0.2236265, 0.5028614),
				float2(0.1722254, 0.983663),
				float2(-0.2912464, 0.8980512),
				float2(-0.8984148, -0.08762786),
				float2(-0.6995085, 0.6734185),
				float2(-0.293196, -0.06289119)
			};

#endif

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				float2 uvs = i.uv;

				half4 normal_raw = tex2D(_MainTex, UnityStereoTransformScreenSpaceTex(uvs));
				//return normal_raw;

				float depth_raw = SAMPLE_DEPTH_TEXTURE_LOD(_CameraDepthTexture, float4(UnityStereoTransformScreenSpaceTex(uvs), 0, 0)).r;

				half mask = tex2D(NGSSEB_EdgeMask, UnityStereoTransformScreenSpaceTex(uvs)).a;

				//skip frag if depth is too close or too far
				if (depth_raw == 1.0 || depth_raw == 0.0 || Linear01Depth(depth_raw) * _ProjectionParams.z > m_bevel_distance || mask == 0.0)// || normal_raw.a == 0)//)
					return normal_raw;

				float depth = LinearEyeDepth(depth_raw);

				float3 normal = normal_raw.xyz * 2.0 - 1.0;

				//scale offset by depth
				float offset = m_bevel_radius / depth;
				float offset_edge = offset * m_edge_offset;
				half3 normal_sum = normal;// 0.0
				//float depth_sum = depth;
				int samplers = Samplers_Count;// * depth;

				UNITY_LOOP
				for (int i = 0; i < samplers; ++i)
				{
					float2 uvs_off = uvs + offset * PoissonDisks[i];

					//skip computation if outside screen
					if (abs(uvs_off.y - 0.5) > 0.5 || abs(uvs_off.x - 0.5) > 0.5)
						continue;

					float depth_off = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_LOD(_CameraDepthTexture, float4(UnityStereoTransformScreenSpaceTex(uvs_off), 0, 0)).r);

					//depth_sum += depth_off;

					float depth_diff = abs(depth - depth_off);

					if (depth_diff - offset_edge)
						uvs_off = lerp(uvs_off, uvs, saturate((depth_diff - offset_edge) * m_edge_distance));//offset

					half3 normal_off = tex2D(_MainTex, UnityStereoTransformScreenSpaceTex(uvs_off)).xyz * 2.0 - 1.0;
					normal_sum += normal_off;
				}
				
				normal_sum = normal_sum / samplers; //normalize(normal_sum);
				//normal_sum = lerp(normal, normal_sum, mask);
				//depth_sum = depth_sum / samplers;
				//normal_sum = normalize(float3(normal_sum.xy + normal.xy, normal_sum.z * normal.z));
				/*
				float blend = dot(normal_sum, normal) * m_edge_thickness;
				normal_sum = lerp(normal_sum, normal, saturate(blend));
				normal_sum = normalize(normal_sum);
				*/
				/*
				float blend = lerp(0.0, 1.0, step(m_edge_thickness, length(depth - depth_sum)));
				normal_sum = lerp(normal, normal_sum, blend);
				*/
				return half4(normal_sum * 0.5 + 0.5, normal_raw.a);//convert to 0-1 range

			}
			ENDCG
		}
	}
}
