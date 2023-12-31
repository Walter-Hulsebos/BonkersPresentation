Shader "Hidden/SC Post Effects/Radial Blur"
{
	HLSLINCLUDE

	#include "../../Shaders/Pipeline/Pipeline.hlsl"

	float4 _Params;
	//X: Amount
	//Y: Center U
	//Z: Center V
	//W: Rotation (Radians)
	float _Iterations;

	#define AMOUNT _Params.x
	#define CENTER float2(_Params.y, _Params.z)
	#define ANGLE _Params.w

	float4 Frag(Varyings input) : SV_Target
	{
		UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

		const float2 direction = CENTER - SCREEN_COORDS.xy;
		const float2 blurVector = direction * (AMOUNT / _Iterations);

		half4 color = half4(0,0,0,0);
		float2 uv = SCREEN_COORDS;
		
		UNITY_LOOP
		for (int j = 0; j < _Iterations; j++)
		{
			float t = (float)j / (float)_Iterations * (AMOUNT * 4.0); //Amount is normalized (*0.25), scale back up to 0-1 range
			uv = RotateUV(uv, CENTER, t * (ANGLE * (1/_Iterations)));
			uv += blurVector;
			
			color += ScreenColor(uv);
		}

		return color / _Iterations;
	}

	ENDHLSL

	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			Name "Radial Blur"
			HLSLPROGRAM
			#pragma multi_compile_vertex _ _USE_DRAW_PROCEDURAL
			#pragma exclude_renderers gles

			#pragma vertex Vert
			#pragma fragment Frag

			ENDHLSL
		}
	}
}