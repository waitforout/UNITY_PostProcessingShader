Shader "Unity Shaders Book/Chapter 12/BrightnessSaturationAndContrast"
{
    Properties
    {
        _MainTex ("Base(RGB", 2D) = "white" {}
        //从脚本传递更好，这里可以直接省略这些值的展示
        _Brightness ("Brightness", float) = 1
        _Saturation ("Saturation", float) = 1
        _Contrast ("Contrast", float) = 1
    }
    SubShader
    {
        Pass
        {
            //关闭深度写入
            ZTest Always Cull Off Zwrite Off

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            //properties
            sampler2D _MainTex;
            half _Brightness;
            half _Saturation;
            half _Contrast;

            struct v2f {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0; 
            };

            //使用了内置的appdata_img结构体作为顶点着色器的输入
            v2f vert(appdata_img  v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                //获得屏幕图像的采样
                fixed4 renderTex = tex2D(_MainTex, i.uv);

                //亮度
                fixed3 finalColor = renderTex.rgb * _Brightness;

                //饱和度
                fixed luminance = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;  //计算该像素的亮度值
                fixed3 luminanceColor = fixed3(luminance, luminance, luminance);  //创建饱和度为0的颜色
                finalColor = lerp(luminanceColor, finalColor, _Saturation);

                //contrast
                fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
                finalColor = lerp(avgColor, finalColor, _Contrast);

                return fixed4(finalColor, renderTex.a);
            }
            ENDCG
        }
    }
    FallBack  Off
}
