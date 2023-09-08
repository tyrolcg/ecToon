#ifndef ecToon_ShadowCaster
#define ecToon_ShadowCaster

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"


float3 _LightDirection;
struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS : NORMAL;
};

struct Varyings
{
    float4 vertex   : SV_POSITION;
};

Varyings vert(Attributes i){
    Varyings o = (Varyings)0;
    UNITY_SETUP_INSTANCE_ID(i);
    float3 positionWS = TransformObjectToWorld(i.positionOS.xyz);
    float3 normalWS = TransformObjectToWorldNormal(i.normalOS);
    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS,normalWS, _LightDirection));

    #if UNITY_REVERSED_Z
    positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #else
    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
    #endif
    o.vertex = positionCS;
    return o;
}

float4 frag(Varyings i) : SV_TARGET{
    return 0;
}

#endif
