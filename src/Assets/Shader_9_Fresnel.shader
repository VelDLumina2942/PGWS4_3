Shader "Custom/Shader_9_Fresnel"
{
    Properties
    {

      _Fresnel0("Fresnel0",Range(0,0.99999))=0.8
      _Fresnel1("Fresnel1",Range(0,0.99999))=0.8
      _Fresnel2("Fresnel2",Range(0,0.99999))=0.8
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
                float3 normal:NORMAL;
                //float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normal:NORMAL;
                float3 position: TEXCOORD0;
                //float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
               half _Fresnel0;
               half _Fresnel1;
               half _Fresnel2;
                
                //float4 _BaseMap_ST;
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
            half FresnelReflectanceAverageDielectric(float co,float f0)
            {
                float root_f0=sqrt(f0);
                float n=(1+root_f0)/(1-root_f0);
                float n2=n*n;

                float si2=1-co*co;
                float nb=sqrt(n2-si2);
                float bn=nb/n2;

                float r_s=(co-nb)/(co+nb);
                float r_p=(co-bn)/(co+bn);
                return 0.5*(r_s*r_s+r_p*r_p);
            }

            half4 frag(Varyings IN) : SV_Target
            {
               Light light=GetMainLight();
               half3 normal=normalize(IN.normal);
               half3 view_direction=normalize(TransformViewToWorld(float3(0,0,0))-IN.position);
               float3 half_vector=normalize(view_direction+light.direction);
               half VdotH=max(0,dot(view_direction,half_vector));
               
               half F0=_Fresnel0+(1-_Fresnel0)*pow(1-VdotH,5);
               half F1=_Fresnel1+(1-_Fresnel1)*pow(1-VdotH,5);
               half F2=_Fresnel2+(1-_Fresnel2)*pow(1-VdotH,5);

               //half F=FresnelReflectanceAverageDielectric(VdotH,_Fresnel0);
               //half F=_Fresnel0+(1-_Fresnel0)*exp(-6*VdotH);

               half3 color=(F0,F1,F2);

               return half4 (color,1);
            }
            ENDHLSL
        }
    }
}