Shader "Custom/ecToon"
{
    Properties
    {
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        [NoScaleOffset]_Shadow_Tex("Shadow Texture", 2D) = "_MainTex"{}
        _Shadow_col("Shadow color", Color) = (1,1,1,1)
        _Shadow_threshold("Shadow Threshold", Range(0.0, 1.0)) = 0.6
        [Toggle]_isLim ("Lim light", int) = 0.0
        _Lim_intensity ("Lim light intensity", float) = 1.0
        _Lim_power ("Lim light power", float) = 2.0
        [HDR]_Lim_color ("Lim light color", color) = (1,1,1,1)
        [KeywordEnum(NONE, VERTCOLOR, FACE)] _Outline_Method ("Outline Method", Int) = 0
        _Outline_color ("Outline color", Color) = (0,0,0,1)
        _Outline_thickness("Outline thickness", float) = 1
        _Outline_tress ("Outline color tress", Range(0.0, 1.0)) = 0.0
    }

    SubShader
    {

        Tags {
            "RenderType"="Opaque"
            "Queue"="Geometry"
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
            
            #ifdef _ALPHA_OPAQUE
            #pragma multi_compile_fog
            #pragma multi_compile _ _ADDITIONAL_LIGHTS _ADDITIONAL_LIGHTS_VERTEX
            
            #include "ecToon_hlsl/ecToon_Core.hlsl"
            #pragma vertex vert
            #pragma fragment frag
            
            #endif
            ENDHLSL
        }
        
        // shadow caster
        Pass{
            Name "Shadow Caster"
            Tags{"LightMode"="ShadowCaster"}
            
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
