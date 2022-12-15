using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class GaussianBlur : MonoBehaviour
{
    public Shader blurShader;
    public Material blurMaterial;
    [Header("��������")]
    [Range(0, 4)]
    public int  blurIterations = 1;

    [Header("ģ����Χ")]
    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.2f;

    [Header("������ϵ��")]
    [Range(1, 8)]
    public int downSample = 2;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(blurMaterial != null)
        {
            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            //���建��rt
            RenderTexture rt0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            rt0.filterMode = FilterMode.Bilinear;  //�����˲�ģʽ

            //��source���ź󣬴浽��rt0��
            Graphics.Blit(source, rt0, blurMaterial);

            //��ʼ����ģ��
            for (int i = 0; i < blurIterations; i++)
            {
                blurMaterial.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                RenderTexture rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                //��һ��Pass
                Graphics.Blit(rt0, rt1, blurMaterial, 0);
                RenderTexture.ReleaseTemporary(rt0);  //��rt0�ͷ�
                rt0 = rt1;  //�ѵ�һ��Pass�Ľ����rt0
                rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);  //�������µ�rt1

                //�ڶ���Pass
                Graphics.Blit(rt0, rt1, blurMaterial, 1);
                RenderTexture.ReleaseTemporary(rt0);
                rt0 = rt1; //����������һ�������ģ�����еĻ���
            }

            //������
            Graphics.Blit (rt0, destination, blurMaterial);
            //�ͷŻ���
            RenderTexture.ReleaseTemporary(rt0);

        }
        else
        {
            Debug.Log("Please input your Material");
            Graphics.Blit(source, destination);
        }
    }
}
