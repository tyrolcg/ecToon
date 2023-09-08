Shader "Custom/ecToon"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _MainColor("Main Color", Color) = (1,1,1,1)
        [NoScaleOffset]_Shadow_Tex("Shadow Texture", 2D) = "white"{}
        _Shadow_col("Shadow Color", Color) = (0.8,0.8,0.8,1)
        _Shadow_threshold("Shadow Threshold", Range(0.0, 1.0)) = 0.6
        [KeywordEnum(NONE, ALWAYS, WITH_DIRECTIONAL_LIGHT)]_LimLightSetting ("Lim light", int) = 0.0
        _Lim_intensity ("Lim light intensity", float) = 1.0
        _Lim_power ("Lim light power", float) = 2.0
        [HDR]_Lim_color ("Lim light color", color) = (1,1,1,1)
        [KeywordEnum(NONE, VERTCOLOR, FACE)] _Outline_Method ("Outline Method", Int) = 0
        _Outline_color ("Outline color", Color) = (0,0,0,1)
        _Outline_thickness("Outline thickness", float) = 1
        _Outline_tress ("Outline color tress", Range(0.0, 1.0)) = 0.0
        [Toggle]_envLight ("Environment Light", int) = 1.0
        [Toggle]_noise("Noise", int) = 0.0
        _noiseScale("Noise Scale", float) = 5000
    }

    SubShader
    {

        Tags {
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100

        ZWrite on


        Pass
        {
            Name "ForwardLit"
            Tags{
                "LightMode" = "UniversalForward"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            cull off

            HLSLPROGRAM
            #pragma multi_compile _ALPHA_OPAQUE
            
            #pragma multi_compile_fog
            #pragma multi_compile _ _ADDITIONAL_LIGHTS _ADDITIONAL_LIGHTS_VERTEX
            #pragma multi_compile _ _LIMLIGHTSETTING_NONE _LIMLIGHTSETTING_ALWAYS _LIMLIGHTSETTING_WITH_DIRECTIONAL_LIGHT
            
            #include "ecToon_hlsl/ecToon_Core.hlsl"
            #pragma vertex vert
            #pragma fragment frag
            
            ENDHLSL
        }
        
        // shadow caster
        Pass{
            Name "Shadow Caster"
            Tags{"LightMode"="ShadowCaster"}
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite On
            ZTest LEqual
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "ecToon_hlsl/ecToon_ShadowCaster.hlsl"
            ENDHLSL
        }
        //outline
        Pass{
            Name "Outline"
            Tags{
            }
            cull front


            HLSLPROGRAM
            #pragma multi_compile_fog

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _OUTLINE_METHOD_NONE _OUTLINE_METHOD_VERTCOLOR _OUTLINE_METHOD_FACE
            #include "ecToon_hlsl/ecToon_outline.hlsl"

            ENDHLSL
        }

    }
}
