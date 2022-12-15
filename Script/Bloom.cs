//jiujiu345
//2022.11.14
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using UnityEngine;

[ExecuteInEditMode]
public class Bloom : MonoBehaviour
{
    public Shader bloomShader;
    public Material bloomMaterial;
    [Header("模糊迭代次数")]
    [Range(0, 4)]
    public int interations = 2;

    [Header("模糊范围")]
    [Range(0.3f, 3.0f)]
    public float blurSpread = 0.3f;

    [Header("降采样次数")]
    [Range(1, 8)]
    public int downSample = 1;

    //控制提取较亮区域时使用的阈值大小
    //开启HDR后，亮度值会超过1，所以范围在1~4
    [Header("阈值")]
    [Range(0.0f, 4.0f)]
    public float luminanceThreshold = 0.6f;
    public void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
        if(bloomMaterial != null)
        {
            bloomMaterial.SetFloat("_LuminanceThreshold", luminanceThreshold);

            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            //定义rt
            RenderTexture rt0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            rt0.filterMode = FilterMode.Bilinear;
            //第一个Pass提取图片较亮的部分
            Graphics.Blit(source, rt0, bloomMaterial, 0);

            for(int i = 0; i < interations; i++)
            {
                bloomMaterial.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                //第二个Pass
                //0给了1，0被释放，1给了0，1再重新赋
                Graphics.Blit(rt0, rt1, bloomMaterial, 1);
                RenderTexture.ReleaseTemporary(rt0);
                rt0 = rt1;
                rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                //第三个Pass
                Graphics.Blit(rt0, rt1, bloomMaterial, 2);
                RenderTexture.ReleaseTemporary(rt0);
                rt0 = rt1;
            }
            //rt0储存模糊后的图片
            bloomMaterial.SetTexture("_Bloom", rt0);
            //第四个Pass-混合
            Graphics.Blit(source, destination, bloomMaterial, 3);
            RenderTexture.ReleaseTemporary(rt0);
        }
        else
        {
            Debug.Log("Please input your Material");
            Graphics.Blit(source, destination);
        }
    }

}
