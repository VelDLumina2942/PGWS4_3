Shader "Custom/Shader_16_MyShader"

{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _SpecularIntensity("Specular Intensity",Range(0,1))=0.3
        _AmbientRate("Ambient Rate",Range(0,1))=0.2
        _Fresnel0("Fresnel0",Range(0,0.99999))=0.8
        _RoughnessX("Roughness X",Range(0,1))=0.8
        _RoughnessY("Roughness Y",Range(0,1))=0.2
        _Metallic("Metallic",Range(0,1))=0.5
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
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                //float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
                float3 position: TEXCOORD0;
                //float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half _Fresnel0;
                half _SpecularIntensity;
                half _AmbientRate;
                half _RoughnessX;
                half _RoughnessY;
                half _Metallic;
                
                //float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normal=TransformObjectToWorldNormal(IN.normal);
                OUT.tangent=float4(TransformObjectToWorldNormal(float3(IN.tangent.xyz)).xyz,IN.tangent.w);
                OUT.position=TransformObjectToWorld(IN.positionOS.xyz);
                //OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
               Light light=GetMainLight();
               half3 normal=normalize(IN.normal);
               half3 binormal=normalize(cross(normal,IN.tangent.xyz)*IN.tangent.w);
               half3 tangent =cross(binormal,normal)*IN.tangent.w;
               half3 view_direction=normalize(TransformViewToWorld(float3(0,0,0))-IN.position);
               float3 half_vector=normalize(view_direction+light.direction);
               half VdotN=max(0.000001,dot(view_direction,normal));
               half LdotN=max(0.000001,dot(light.direction,normal));
               half HdotN=max(0.000001,dot(half_vector,normal));

               half LdotH=max(0,dot(half_vector,light.direction));
               half VdotH=max(0,dot(half_vector,view_direction));
               //half LdotN=max(0,dot(light.direction,normal));

               half alphaX=_RoughnessX*_RoughnessX;
               half alphaY=_RoughnessY*_RoughnessY;
               half XdotH =dot(tangent,half_vector);
               half YdotH =dot(binormal,half_vector);
               
               half alpha2=alphaX+alphaY;
               float D=exp(-(1-HdotN*HdotN)/(HdotN*HdotN*alpha2))/(4*alpha2*HdotN*HdotN*HdotN*HdotN);
                half G=min(1,2*min(HdotN*VdotN/VdotH,HdotN*LdotN/LdotH));
               half F=_Fresnel0+(1-_Fresnel0)*pow(1-VdotH,5);

               half3 ambient=_BaseColor.rgb;
               half3 lambert=_BaseColor.rgb*LdotN;
               half c=(XdotH*XdotH/(alphaX*alphaX)+YdotH*YdotH/(alphaY*alphaY))/(HdotN*HdotN);
               half3 specular=_SpecularIntensity*exp(-c)/sqrt(LdotN*VdotN)/(4*PI*alphaX*alphaY);
               //float3 half_vectorÇ©ÇÁhalf3 specularÇ‹Ç≈Ç∆ìØÇ∂èàóù
               //half3 specular =LightingSpecular(1,light.direction,normal,view_direction,_SpecularIntensity,_SpecularPower);
               
               //half3 braf=_BaseColor* D*G*F/(4*LdotN*VdotN);
               half3 braf=D*G*F/(4*LdotN*VdotN);

               half3 color=light.color*lerp(lerp(lambert,ambient,_AmbientRate),specular,_Metallic)*LdotN*braf;

               return half4 (color,1);
            }
            ENDHLSL
        }
    }
}