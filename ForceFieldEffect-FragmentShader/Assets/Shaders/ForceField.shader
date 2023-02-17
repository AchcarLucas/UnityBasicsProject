Shader "Unlit/ForceField"
{
    Properties
    {
        [HDR] _OutlineColor ("OutlineColor", Color) = (0.0, 0.0, 0.5, 0.2)
        _MainTex ("Texture", 2D) = "white" {}
        _Offset ("Offset Substract", float) = 0.2
        _Fill ("Fill", Color) = (0.0, 0.0, 0.5, 0.2)
        _Fresnel ("Fresnel Effect", float) = 5
        _SpeedOffsetTexture ("Speed Offset Texture", float) = 0.05
    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members uv)
#pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 screenPosition : TEXCOORD1;
                float3 worldPosition : TEXCOORD2;
                float3 normal : TEXCOORD3;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float3 ViewDir;

            float4 _OutlineColor;

            float4 _MainTex_ST;
            float4 _Fill;

            float _Offset;
            float _Fresnel;

            float _SpeedOffsetTexture;

            v2f vert (appdata v)
            {
                v2f o;

                o.normal = v.normal;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.worldPosition = mul(unity_ObjectToWorld, float4(v.vertex.xyz, 1.0)).xyz - _WorldSpaceCameraPos;
                o.screenPosition = ComputeScreenPos(o.vertex);

                UNITY_TRANSFER_FOG(o, o.vertex);

                return o;
            }

            float Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power)
            {
                return pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 tex = tex2D(_MainTex, i.uv + _Time.y * _SpeedOffsetTexture);
                UNITY_APPLY_FOG(i.fogCoord, tex);

                float2 screenPositionUV = i.screenPosition.xy / i.screenPosition.w;
                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenPositionUV));
                
                // Force Field Effect
                float r = i.screenPosition.w - _Offset;
                r = 1 - (depth - r);
                r = smoothstep(0, 1, r);
                r = (r + Unity_FresnelEffect_float(i.normal, -1 * i.worldPosition, _Fresnel));

                return float4((tex.xyz + _Fill.xyz) * _OutlineColor, r + _Fill.w);
            }
            ENDCG
        }
    }
}
