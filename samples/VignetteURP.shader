Shader "Guide/Vignette (URP)"
{
    Properties
    {
        _Intensity ("Intensity", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" }
        ZTest Always Cull Off ZWrite Off
        Pass
        {
            Name "Vignette"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            // Full-screen triangle vertex shader (Vert) and the source texture (_BlitTexture).
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            float _Intensity;

            half4 Frag (Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float2 uv = input.texcoord;
                half4 color = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);
                float2 d = uv - 0.5;
                color.rgb *= saturate(1.0 - dot(d, d) * _Intensity * 2.0);
                return color;
            }
            ENDHLSL
        }
    }
}
