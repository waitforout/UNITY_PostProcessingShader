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
    [Header("ģ����������")]
    [Range(0, 4)]
    public int interations = 2;

    [Header("ģ����Χ")]
    [Range(0.3f, 3.0f)]
    public float blurSpread = 0.3f;

    [Header("����������")]
    [Range(1, 8)]
    public int downSample = 1;

    //������ȡ��������ʱʹ�õ���ֵ��С
    //����HDR������ֵ�ᳬ��1�����Է�Χ��1~4
    [Header("��ֵ")]
    [Range(0.0f, 4.0f)]
    public float luminanceThreshold = 0.6f;
    public void OnRenderImage (RenderTexture source, RenderTexture destination)
    {
        if(bloomMaterial != null)
        {
            bloomMaterial.SetFloat("_LuminanceThreshold", luminanceThreshold);

            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            //����rt
            RenderTexture rt0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            rt0.filterMode = FilterMode.Bilinear;
            //��һ��Pass��ȡͼƬ�����Ĳ���
            Graphics.Blit(source, rt0, bloomMaterial, 0);

            for(int i = 0; i < interations; i++)
            {
                bloomMaterial.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                //�ڶ���Pass
                //0����1��0���ͷţ�1����0��1�����¸�
                Graphics.Blit(rt0, rt1, bloomMaterial, 1);
                RenderTexture.ReleaseTemporary(rt0);
                rt0 = rt1;
                rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                //������Pass
                Graphics.Blit(rt0, rt1, bloomMaterial, 2);
                RenderTexture.ReleaseTemporary(rt0);
                rt0 = rt1;
            }
            //rt0����ģ�����ͼƬ
            bloomMaterial.SetTexture("_Bloom", rt0);
            //���ĸ�Pass-���
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
