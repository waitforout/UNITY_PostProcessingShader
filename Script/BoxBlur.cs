using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class BoxBlur : MonoBehaviour
{
    public Shader blurShader;
    public Material blurMaterial;
    [Header("迭代次数")]
    [Range(0, 4)]
    public int blurIterations = 1;

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
            RenderTexture rt = RenderTexture.GetTemporary(rtW, rtH, 0);

            //把source缩放后，存到了rt上
            Graphics.Blit(source, rt, blurMaterial);

            //开始迭代模糊
            for (int i = 0; i < blurIterations; i++)
            {
                blurMaterial.SetFloat("_BlurSize", blurSpread);
                Graphics.Blit(rt, source, blurMaterial);
                Graphics.Blit(source, rt, blurMaterial);
            }
            //输出结果
            Graphics.Blit (rt, destination, blurMaterial);
            //释放缓存
            RenderTexture.ReleaseTemporary(rt);

        }
        else
        {
            Debug.Log("Please input your Material");
            Graphics.Blit(source, destination);
        }
    }
}
