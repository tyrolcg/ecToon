#ifndef ecToon_lighting
#define ecToon_lighting

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

/*
struct Light
{
    half3   direction;
    half3   color;
    half    distanceAttenuation;
    half    shadowAttenuation;
};
*/

//shadow
TEXTURE2D(_Shadow_Tex);
SAMPLER(sampler_Shadow_Tex);
float4 _Shadow_Tex_ST;
float4 _Shadow_col;
float4 _Shadow_col_2;
float _Shadow_threshold;
float _Shadow_threshold_2;

//lim
float _Lim_intensity;
float _Lim_power;
float4 _Lim_color;

float3 Calc_color_with_light(Light light){
    float3 col_light = light.color;

    return col_light;
}

float3 CalcDirectionLightEffect(Light light, float3 normal, float threshold){
    float power = dot(light.direction, normal) / 2;
    power += 0.5;
    power = step(power, threshold) * power;

    return power;
}

//影の色と閾値を計算
float4 CalcShadow(float4 colorBase, Light light, float2 uv, float3 normal){
    float4 shadowColor = SAMPLE_TEXTURE2D(_Shadow_Tex, sampler_Shadow_Tex, uv) * _Shadow_col;

    float power = dot(light.direction, normal)/2;
    power += 0.5;
    // if power <= _shadow_threshold s = 1, else s = 0
    float s = step(power, _Shadow_threshold);
    float4 color = lerp(colorBase, shadowColor, s);
    return color;
}


float3 VertexLighting(float3 positionWS, float3 normalWS)
{
    float3 vertexLightColor = float3(0,0,0);

    #ifdef _ADDITIONAL_LIGHTS_VERTEX
    uint lightsCount = GetAdditionalLightsCount();
    for(uint lightIndex = 0u; lightIndex < lightsCount; ++lightIndex)
    {
        // lightIndexから対応するライト構造体を取得する
        Light light = GetAdditionalLight(lightIndex, positionWS);
        //光の減衰
        float3 lightColor = light.color * light.distanceAttenuation;
        // float distance = length(_AdditionalLightsPosition[lightIndex] - positionWS);
        float power = dot(light.direction, normalWS)/2;
        power += 0.5;
        // if power <= _shadow_threshold s = 1, else s = 0
        float s = step(power, _Shadow_threshold);
        vertexLightColor += lightColor * (1 - s) / (10);
        //vertexLightColor += LightingLambert(lightColor, light.direction, normalWS);
    }
    #endif
    return vertexLightColor;
}

//ピクセルシェーダーのAdditional Lighting
float3 AdditionalPixelLighting(float3 positionWS, float3 normalWS)
{
    float3 pixelLightColor = float3(0,0,0);

    #ifdef _ADDITIONAL_LIGHTS
    uint lightsCount = GetAdditionalLightsCount();
    for(uint lightIndex = 0u; lightIndex < lightsCount; ++lightIndex)
    {
        // lightIndexから対応するライト構造体を取得する
        Light light = GetAdditionalLight(lightIndex, positionWS);
        //光の減衰
        float3 lightColor = light.color * light.distanceAttenuation;

        float power = dot(light.direction, normalWS) / 2;
        power += 0.5;
        // if power <= _shadow_threshold s = 1, else s = 0
        float s = step(power, _Shadow_threshold);
        pixelLightColor += lightColor * (1 - s) / (10);
        // pixelLightColor += float3(0.1,0.1,0.1);
    }
    //pixelLightColor = float3(1,1,1);
    #endif
    return pixelLightColor;
}
//リムライト
float3 CalcLimLight(float3 normalInView, float3 normalWS, Light light, float intensity, float limPower){

    intensity = max(intensity, 0);
    limPower = max(limPower, 0);

    //法線と入射方向に対する強度
    float power1 = 1 - max(0, dot(normalize(light.direction), normalize(normalWS)));

    //視線と入射方向に対する強度
    normalInView = normalize(normalInView);
    float power2 = 1 - max(0, normalInView.z);

    //視線とライトの方向が逆のときリムライトを出す
    float3 ViewZ = UNITY_MATRIX_V[2].xyz;
    float power3 = max(0, dot(normalize(light.direction), normalize(-ViewZ)));

    float power = abs(power1 * power2 * power3);
    power = pow(power, limPower) * intensity;
    float3 col = float3(_Lim_color.xyz) * light.color * power;
    return col;
}

#endif