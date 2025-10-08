Shader "Custom/Material_4_Specular"
{
    Properties
    {
        //[MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _SpecularPower("Specular Power",Range(0.001,300))=80
        _SpecularIntensity("Specular Intensity",Range(0,1))=0.3
        //[MainTexture] _BaseMap("Base Map", 2D) = "white"
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normal:NORMAL;//ここにも書かないと使えない
                //float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normal : NORMAL;
                float3 position : TEXCOORD0;
                //float2 uv : TEXCOORD0;
            };

            //TEXTURE2D(_BaseMap);
            //SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                //half4 _BaseColor;
                //float4 _BaseMap_ST;
                half _SpecularPower;
                half _SpecularIntensity;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normal=TransformObjectToWorldNormal(IN.normal);
                OUT.position=TransformObjectToWorld(IN.positionOS.xyz);
                //OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light light=GetMainLight();
                half3 normal=normalize(IN.normal);
                half3 view_direction=normalize(TransformViewToWorld(float3(0,0,0))-IN.position);
                //  ↑
                //　｜ 厳密には違う近似処理
                //　↓ 下は頂点の位置を見ない処理、上と比べて軽い処理のためよく使われる
                //half3 view_direction=TransformViewToWorldNormal(float(0,0,1));

                float3 reflected_direction=-light.direction+2*normal*dot(light.direction,normal);
                //float3 reflected_direction=reflect(-light.direction,normal);

                half3 specular=_SpecularIntensity*pow(max(0,dot(reflected_direction,view_direction)),_SpecularPower);

                half3 color=light.color*specular;

                //half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv) * _BaseColor;
                return half4 (color,1);
            }
            ENDHLSL
        }
    }
}

