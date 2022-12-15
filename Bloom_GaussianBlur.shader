//jiujiu345
//2022.11.14
Shader "Unity Shaders Book/Chapter 12/Bloom_GaussianBlur"
{
    Properties
    {
        _MainTex ("Base(RGB)", 2D) = "white" {} //src
        _Bloom("Bloom(RGB)", 2D) = "black" {} //高斯模糊后的较亮区域
        //_LuminanceThreshold("Luminance Threshold", Float) = 0.5  //提取较亮区域的阈值
        //_BlurSize("Blur Size", Float) = 1.0  //模糊区域范围
    }
    SubShader
    {
        CGINCLUDE

        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        sampler2D _Bloom;
        float _LuminanceThreshold;
        float _BlurSize;

        //Pass0-提取较亮区域
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
            fixed4 c = tex2D(_MainTex, i.uv);
            fixed val = saturate(Luminance(c) - _LuminanceThreshold);
            return val * c;
        }

        //Pass2&3-高斯模糊
        struct v2f_Gaussian {
            float4 pos : SV_POSITION;
            half2 uv[5] : TEXCOORD0;  
        };

        //水平
        v2f_Gaussian vertBlurVertical(appdata_img v) {
            v2f_Gaussian o;
            o.pos = UnityObjectToClipPos(v.vertex);
            half2 uv = v.texcoord;

            o.uv[0] = uv;
            o.uv[1] = uv + float2(0.0f, _MainTex_TexelSize.y * 1.0 * _BlurSize);
            o.uv[2] = uv - float2(0.0f, _MainTex_TexelSize.y * 1.0 * _BlurSize);
            o.uv[3] = uv + float2(0.0f, _MainTex_TexelSize.y * 2.0 * _BlurSize);
            o.uv[4] = uv - float2(0.0f, _MainTex_TexelSize.y * 2.0 * _BlurSize);

            return o;
        }

        //竖直
        v2f_Gaussian vertBlurHorizontal(appdata_img v) {
            v2f_Gaussian o;
            o.pos = UnityObjectToClipPos(v.vertex);
            half2 uv = v.texcoord;

            o.uv[0] = uv;
            o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0 * _BlurSize, 0.0f);
            o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0 * _BlurSize, 0.0f);
            o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0 * _BlurSize, 0.0f);
            o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0 * _BlurSize, 0.0f);

            return o;
        }

        fixed4 GaussianBlur(v2f_Gaussian i) : SV_Target {
            float weight[3] = {0.4026, 0.2442, 0.0545};
            fixed3 color = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
            
            for(int j=1;j<3;j++) {
                color += tex2D(_MainTex, i.uv[2*j-1]).rgb * weight[j];
                color += tex2D(_MainTex, i.uv[2*j]).rgb * weight[j];
            }
            return fixed4(color, 1.0);
        }

        //Pass3-混合亮度和原图
        struct v2f_Bloom {
            float4 pos : SV_POSITION;
            half4 uv : TEXCOORD0;
        };

        v2f_Bloom vertBloom(appdata_img v) {
            v2f_Bloom o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv.xy = v.texcoord;
            o.uv.zw = v.texcoord;

            //用以判断是否在Direct3D平台
            #if UNITY_UV_STARTS_AT_TOP
            if(_MainTex_TexelSize.y < 0.0) {
                o.uv.w = 1.0 - o.uv.w;
            }
            #endif

            return o;
        }

        fixed4 fragBloom(v2f_Bloom i) : SV_Target {
            return tex2D(_MainTex, i.uv.xy) + tex2D(_Bloom, i.uv.zw);
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
            #pragma vertex vertBlurVertical
            #pragma fragment GaussianBlur

            ENDCG
        }

        Pass {
            CGPROGRAM
            #pragma vertex vertBlurHorizontal
            #pragma fragment GaussianBlur

            ENDCG
        }

        Pass {
            CGPROGRAM
            #pragma vertex vertBloom
            #pragma fragment fragBloom

            ENDCG
        }
    }
    FallBack  Off
}
