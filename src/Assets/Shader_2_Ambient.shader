Shader "Custom/Shader_2_Ambient"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"//for add Directional Light Data

            struct Attributes
            {
                float4 positionOS : POSITION;
                //float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                //float2 uv : TEXCOORD0;
            };

            //TEXTURE2D(_BaseMap);
            //SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                //float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                //OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light light=GetMainLight();//add Directional Light Data　←intensityが一番高いディレクショナルライトが割り当てられるらしい
                //GetAddtionalLight（lightindex,positonInWorldSpace）で他のライトを追加して設定すればディレクショナル以外もできそう？追加分全部読み込むとかの使い方が多そう？上限が8までだから指定は簡単そう

                half3 color=light.color*_BaseColor.rgb;
                //　↑
                //　｜　同一の結果になるコード
                //　↓
                //half3 color;
                //color.r=light.color.r*_BaseColor.r;
                //color.g=light.color.r*_BaseColor.g;
                //color.b=light.color.r*_BaseColor.b;
                
                return half4(color,1);
            }
            ENDHLSL
        }
    }
}
