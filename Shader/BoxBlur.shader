Shader "Unity Shaders Book/Chapter 12/BoxBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        ZTest Always
        Cull Off
        ZWrite Off
        Pass {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment BoxBlur
            #include "UnityCG.cginc"

            //properties
            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            float _BlurSize;

            struct v2f {
                float4 pos : SV_POSITION;
                half2 uv[9] : TEXCOORD0;  
            };

            v2f vert(appdata_img v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                half2 uv = v.texcoord;

                //加入_BlurSize控制采样距离
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1) * _BlurSize;
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1) * _BlurSize;
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1) * _BlurSize;
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0) * _BlurSize;
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0) * _BlurSize;
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0) * _BlurSize;
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1) * _BlurSize;
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1) * _BlurSize;
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1) * _BlurSize;

                return o;
            }

            fixed3 BoxBlur(v2f i) : SV_Target {
                fixed4 color = fixed4(0, 0, 0, 0);
                for(int j=0;j<9;j++){
                    color +=tex2D(_MainTex, i.uv[j]);
                }
                return color/9.0;
            }
            ENDCG
        }
    }
}
