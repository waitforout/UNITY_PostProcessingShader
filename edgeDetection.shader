Shader "Unity Shaders Book/Chapter 12/edgeDetectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeOnly ("EdgeOnly", float) = 1.0
        _EdgeColor ("EdgeColor", Color) = (0, 0, 0, 1)
        _BackgroudColor ("BackgroundColor", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragSobel
            #include "UnityCG.cginc"

            //properties
            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroudColor;

            struct v2f {
                float4 pos : SV_POSITION;
                half2 uv[9] : TEXCOORD0; 
            };

            v2f vert(appdata_img v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                half2 uv = v.texcoord;

                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);

                return o;
            }

            fixed luminance(fixed4 color) {
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }
            //自定义一个Sobel算子
            half Sobel(v2f i) {
                //定义卷积核：
                const half Gx[9] = 
                {
                    -1, 0, 1,
                    -2, 0, 2,
                    -1, 0, 1
                };
                const half Gy[9] =
                {
                    -1, -2, -1,
                    0, 0, 0, 
                    1, 2, 1
                };
                half texColor;
                half edgeX = 0;
                half edgeY = 0;
                for(int j=0;j<9;j++) {
                    texColor = luminance(tex2D(_MainTex, i.uv[j]));  //依次对9个像素采样，计算明度值
                    edgeX += texColor * Gx[j];
                    edgeY += texColor * Gy[j];
                }

                half edge = 1 - abs(edgeX) - abs(edgeY); //绝对值代替开根号求模，节省开销
                //half edge = 1 - pow(edgeX*edgeX + edgeY*edgeY, 0.5);
                return edge;
            }

            fixed4 fragSobel(v2f i) : SV_Target {
                half edge = Sobel(i);

                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);  //4是原始像素位置
                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroudColor, edge);
                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
            }

            
            ENDCG
        }
    }
    FallBack  Off
}
