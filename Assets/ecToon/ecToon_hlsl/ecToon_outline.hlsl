#ifndef ecToon_outline
#define ecToon_outline


#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

float _Outline_thickness;
float4 _Outline_color;
float _Outline_tress;

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
float4 _MainTex_ST;

float4 outline_color(){

    return _Outline_color;
}

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    float4 tangentOS  : TANGENT;
    float4 vertColor : COLOR;
    float2 uv : TEXCOORD0;
};

struct Varyings
{
    float4 vertex   : SV_POSITION;
    float  fogCoord : TEXCOORD1;
    float3 normal : NORMAL0;
    float2 uv : TEXCOORD0;
};

Varyings vert(Attributes i){
    Varyings o = (Varyings)0;

    o.normal = TransformObjectToWorldNormal(i.normalOS);


    #ifdef _OUTLINE_METHOD_NONE
        i.positionOS = float4(0,0,0,0);
    #elif _OUTLINE_METHOD_VERTCOLOR
        float thick = _Outline_thickness * 0.005;
        float3 n = normalize(i.vertColor.xyz);
        i.positionOS.xyz += n * thick;
    #elif _OUTLINE_METHOD_FACE
        float thick = _Outline_thickness * 0.005;
        float3 n = normalize(i.normalOS);
        i.positionOS.xyz += n * thick;
    #endif
    o.vertex = TransformObjectToHClip(i.positionOS.xyz);
    o.uv = TRANSFORM_TEX(i.uv, _MainTex);

    return o;
}

float4 frag(Varyings i) : SV_TARGET{
    float4 col = outline_color();
    Light light = GetMainLight();
    col *= float4(light.color, 1);
    float4 col_origin = col;
    
    float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
    texColor *= float4(light.color, 1);
    col = lerp(col_origin, texColor, _Outline_tress);
    return col;
}
#endif
