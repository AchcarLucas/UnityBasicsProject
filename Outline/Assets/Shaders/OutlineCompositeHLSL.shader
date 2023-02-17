Shader "Unlit/OutlineCompositeHLSL"
{
    HLSLINCLUDE

        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        float4 _MainTex_TexelSize;

        TEXTURE2D_SAMPLER2D(_OutlineTex, sampler_OutlineTex);
        float4 _OutlineTex_TexelSize;

        TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
        float4x4 unity_MatrixMVP;

        half4 _Color;

        struct v2f
        {
            float2 uv : TEXCOORD0;
            float4 vertex : SV_POSITION;
            float3 screenPosition : TEXCOORD2;
        };

        inline float4 ComputeScreenPos(float4 pos) 
        {
            float4 o = pos * 0.5f;
            o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w;
            o.zw = pos.zw;
            return o;
        }

        v2f Vert(AttributesDefault v)
        {
            v2f o;

            o.vertex = float4(v.vertex.xy, 0.0, 0.1);

            o.uv = TransformTriangleVertexToUV(v.vertex.xy);
            o.screenPosition = ComputeScreenPos(o.vertex);

            #if UNITY_UV_STARTS_AT_TOP
                o.uv = o.uv * float(1.0, -1.0) + float2(0.0, 1.0);
            #endif

            return o;
        }

        float4 Frag(v2f i) : SV_Target
        {
            float4 m_tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
            float4 o_tex = SAMPLE_TEXTURE2D(_OutlineTex, sampler_OutlineTex, i.uv);

            o_tex.rgb *= _Color;

            float4 output = lerp(m_tex, o_tex, o_tex.a);
            
            return output;
        }

    ENDHLSL

    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM

                #pragma vertex VertDefault
                #pragma fragment Frag

            ENDHLSL
        }
    }
}