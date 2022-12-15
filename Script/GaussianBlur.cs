using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class GaussianBlur : MonoBehaviour
{
    public Shader blurShader;
    public Material blurMaterial;
    [Header("迭代次数")]
    [Range(0, 4)]
    public int  blurIterations = 1;

    [Header("模糊范围")]
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.2f;

    [Header("降采样系数")]
    [Range(1, 8)]
    public int downSample = 2;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(blurMaterial != null)
        {
            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            //定义缓存rt
            RenderTexture rt0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            rt0.filterMode = FilterMode.Bilinear;  //设置滤波模式

            //把source缩放后，存到了rt0上
            Graphics.Blit(source, rt0, blurMaterial);

            //开始迭代模糊
            for (int i = 0; i < blurIterations; i++)
            {
                blurMaterial.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                RenderTexture rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                //第一个Pass
                Graphics.Blit(rt0, rt1, blurMaterial, 0);
                RenderTexture.ReleaseTemporary(rt0);  //把rt0释放
                rt0 = rt1;  //把第一个Pass的结果给rt0
                rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);  //创建个新的rt1

                //第二个Pass
                Graphics.Blit(rt0, rt1, blurMaterial, 1);
                RenderTexture.ReleaseTemporary(rt0);
                rt0 = rt1; //继续进行下一个迭代的（如果有的话）
            }

            //输出结果
            Graphics.Blit (rt0, destination, blurMaterial);
            //释放缓存
            RenderTexture.ReleaseTemporary(rt0);

        }
        else
        {
            Debug.Log("Please input your Material");
            Graphics.Blit(source, destination);
        }
    }
}
