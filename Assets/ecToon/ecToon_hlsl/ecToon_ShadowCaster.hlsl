#ifndef ecToon_ShadowCaster
#define ecToon_ShadowCaster

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"




struct Attributes
{
    float4 positionOS : POSITION;
};

struct Varyings
{
    float4 vertex   : SV_POSITION;
};

Varyings vert(Attributes i){
    Varyings o = (Varyings)0;
    o.vertex = TransformObjectToHClip(i.positionOS.xyz);
    return o;
}

float4 frag(Varyings i) : SV_TARGET{
    return 0;
}

#endif
