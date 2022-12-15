Shader "Unity Shaders Book/Chapter 12/GaussianBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        //CGINCLUDE--ENDCG中定义的可以定义一系列Pass中会用到的函数，相当于一个头文件的作用：
        CGINCLUDE

        #include "UnityCG.cginc"

        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        float _BlurSize;

        struct v2f {
            float4 pos : SV_POSITION;
            half2 uv[5] : TEXCOORD0;  
        };

        //水平
        v2f vertBlurVertical(appdata_img v) {
            v2f o;
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
        v2f vertBlurHorizontal(appdata_img v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            half2 uv = v.texcoord;

            o.uv[0] = uv;
            o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0 * _BlurSize, 0.0f);
            o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0 * _BlurSize, 0.0f);
            o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0 * _BlurSize, 0.0f);
            o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0 * _BlurSize, 0.0f);

            return o;
        }

        fixed4 GaussianBlur(v2f i) : SV_Target {
            float weight[3] = {0.4026, 0.2442, 0.0545};
            fixed3 color = tex2D(_MainTex, i.uv[0]).rgb * weight[0];
            
            for(int j=1;j<3;j++) {
                color += tex2D(_MainTex, i.uv[2*j-1]).rgb * weight[j];
                color += tex2D(_MainTex, i.uv[2*j]).rgb * weight[j];
            }
            return fixed4(color, 1.0);
        }
        ENDCG

        ZTest Always
        Cull Off
        ZWrite Off

        //水平的Pass
        Pass {
            NAME "GAUSSIANBLUR_BLUR_VERTICAL"
            CGPROGRAM
            
            #pragma vertex vertBlurVertical
            #pragma fragment GaussianBlur

            ENDCG
        }

        //竖直
        Pass {
            NAME "GAUSSIANBLUR_BLUR_HORIZONTAL"
            CGPROGRAM
            
            #pragma vertex vertBlurHorizontal
            #pragma fragment GaussianBlur

            ENDCG
        }
    }
    FallBack  Off
}
