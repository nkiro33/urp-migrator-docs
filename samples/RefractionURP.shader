// URP version of the GrabPass refraction sample, written by hand for the docs guide.
// Needs "Opaque Texture" turned on in the URP asset.
Shader "Guide/Refraction (URP)"
{
    Properties
    {
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _Distortion ("Distortion", Range(0, 0.1)) = 0.03
        _Tint ("Tint", Color) = (0.85, 0.95, 1, 1)
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "Queue"="Transparent" "RenderType"="Transparent" }
        Pass
        {
            Name "Refraction"
            Tags { "LightMode"="UniversalForwardOnly" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _BumpMap_ST;
                float _Distortion;
                half4 _Tint;
            CBUFFER_END
            TEXTURE2D(_BumpMap);
            SAMPLER(sampler_BumpMap);

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
            };

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BumpMap);
                return o;
            }

            half4 frag (Varyings i) : SV_Target
            {
                float2 offset = UnpackNormal(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, i.uv)).xy * _Distortion;
                float2 screenUV = GetNormalizedScreenSpaceUV(i.positionCS);
                half3 background = SampleSceneColor(screenUV + offset);
                return half4(background, 1) * _Tint;
            }
            ENDHLSL
        }
    }
}
