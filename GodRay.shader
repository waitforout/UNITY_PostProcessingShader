Shader "Unity Shaders Book/Chapter 12/GodRay"
{
    Properties
    {
        _MainTex ("Base(RGB)", 2D) = "white" {} //src

        // [Header(Pass0 Extract)]
        // //这些参数可以直接从脚本传递给shader
        // _LuminanceThreshold("Luminance Threshold", Range(0,1)) = 0.5  //提取较亮区域的阈值
        // _LightPosInScreenUV("Light Pos", Vector) = (0.5,0.5,0,0) //模糊中心坐标
        // _LightRadius("Light Radius", Range(0,1)) = 0.5  //光源半径/模糊半径
        // _FactorPow("Pow Factor", Range(0,40)) = 1  //改变亮度有多亮

        // [Header(Pass1 Radial Blur)]
        // _SamplePointNum("Sample Number", Range(1,20)) = 10  //采样点个数
        // _SampleOffset("Sample Offset", Range(0,0.05)) = 0.01  //采样偏移
        // _LightColor("Light Color", Color) = (0, 0, 0, 0)  //光的颜色

        // [Header(Pass2 AddBlur)]
        _RadiusBlur("Blur", 2D) = "black" {} //提取亮区域+径向模糊后的图
    }
    SubShader
    {
        CGINCLUDE

        #define RADIAL_SAMPLE_NUM 10
        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        float _LuminanceThreshold;
        float2 _LightPosInScreenUV;
        float _LightRadius;
        float _FactorPow;

        int _SamplePointNum;
        float _SampleOffset;
        fixed4 _LightColor;

        sampler2D _RadiusBlur;

        //Pass0
        struct v2f_Extract {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0; 
        };

        v2f_Extract vertExtractBright(appdata_img v) {
            v2f_Extract o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }

        //计算像素的亮度
        fixed Luminance(fixed4 color) {
            return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
        }

        //用luminanceThreshold控制亮度强度
        fixed4 fragExtractBright(v2f_Extract i) : SV_Target {
            fixed4 color = tex2D(_MainTex, i.uv);
            //加入亮度+半径的阈值影响：阈值可以看作一个个遮罩
            //1.计算考虑亮度的遮罩
            fixed luminanceMask = saturate(Luminance(color) - _LuminanceThreshold);
            //2.计算考虑亮度+半径的遮罩
            float disFromLight = length(_LightPosInScreenUV.xy - i.uv);
            fixed distanceMask = saturate(_LightRadius -  disFromLight) * luminanceMask;
            return pow(distanceMask, _FactorPow) * color;//加入控制亮度的参数，并输出提取亮度后的图片
        }

        //Pass1
        struct v2f_RadialBlur {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 blurOffset : TEXCOORD1; //每个采样点基于轴心的偏移值
        };

        v2f_RadialBlur vertRadialBlur(appdata_img v) {
            v2f_RadialBlur o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            o.blurOffset = _SampleOffset * (_LightPosInScreenUV.xy - o.uv); //考虑到沿着半径的偏移
            return o;
        }

        fixed4 fragRadialBlur(v2f_RadialBlur i) : SV_Target {
            fixed4 resColor = fixed4(0, 0, 0, 0);
            for(int j=0;j<_SamplePointNum;j++) {
                //取每个采样点的加权平均
                resColor += tex2D(_MainTex, i.uv);
                i.uv.xy += i.blurOffset;
            }
            return resColor / _SamplePointNum;
        }

        //Pass2
        struct v2f_Merge {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0; 
        };

        v2f_Merge vertMerge(appdata_img v) {
            v2f_Merge o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;

            //用以判断是否在Direct3D平台
            #if UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y < 0.0) {
                o.uv.y = 1.0 - o.uv.y;
            }
            #endif
            return o;
        }
        fixed4 fragMerge (v2f_Merge i) : SV_Target {
            return tex2D(_MainTex, i.uv) + tex2D(_RadiusBlur, i.uv) * _LightColor;
        }

        ENDCG
        
        ZTest Always
        Cull Off
        ZWrite Off

        Pass {
            CGPROGRAM
            #pragma vertex vertExtractBright
            #pragma fragment fragExtractBright

            ENDCG
        }
        
        Pass {
            CGPROGRAM
            #pragma vertex vertRadialBlur
            #pragma fragment fragRadialBlur

            ENDCG
        }

        Pass {
            CGPROGRAM
            #pragma vertex vertMerge
            #pragma fragment fragMerge

            ENDCG
        }
    }
    FallBack  Off
}
