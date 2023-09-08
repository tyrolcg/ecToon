#ifndef ecToon_Core
#define ecToon_Core

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "ecToon_lighting.hlsl"
#include "ecToon_Math.hlsl"
CBUFFER_START(UnityPerMaterial)
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
float4 _MainTex_ST;
float4 _MainColor;
CBUFFER_END
int _envLight;
int _noise;
float _noiseScale;
int _isLim;
//outline
float _isOutline;

struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    float4 tangentOS  : TANGENT;
    float2 uv         : TEXCOORD0;
};

struct Varyings
{
    float4 vertex   : SV_POSITION;
    float4 positionWS : TEXCOORD3;
    float3 vertexColor : TEXCOORD2;
    float2 uv       : TEXCOORD0;
    float  fogCoord : TEXCOORD1;
    float3 normal : NORMAL0;
};

Varyings vert(Attributes i){
    Varyings o = (Varyings)0;
    o.vertex = TransformObjectToHClip(i.positionOS.xyz);
    o.positionWS = mul(unity_ObjectToWorld, i.positionOS);
    o.uv = TRANSFORM_TEX(i.uv, _MainTex);
    o.normal = TransformObjectToWorldNormal(i.normalOS);
    o.vertexColor = VertexLighting(mul(UNITY_MATRIX_M, i.positionOS).xyz, o.normal);
    return o;
}

float4 frag(Varyings i) : SV_TARGET{

    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    float4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _MainColor;

    //overlay perlin noise(alpha = 0.2)
    col = lerp(col, noise_overlay(col, i.uv, 1, float2(_noiseScale, _noiseScale)), _noise);
    // environment lighting
    float3 ambColor = col.xyz * (float3)SampleSH(i.normal) * _envLight;
    
    Light dirLight = GetMainLight();
    col.xyz = CalcShadow(col, dirLight, i.uv, i.normal);
    float3 colLight = dirLight.color;

    
    
    colLight += CalcLimLight(i.positionWS, i.normal, dirLight, _Lim_intensity, _Lim_power);
    
    colLight = max(colLight, 0);
    colLight += AdditionalPixelLighting(i.positionWS.xyz, i.normal);

    col.xyz *= colLight;
    col.xyz += i.vertexColor;
    col.xyz += ambColor;

    /*end culc lighting*/
    return col;
}

#endif
