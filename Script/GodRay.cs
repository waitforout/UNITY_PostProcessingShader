using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class GodRay : MonoBehaviour
{
    public Shader GodRayShader;
    public Material GodRayMaterial;
    [Header("ģ����������")]
    [Range(0, 4)]
    public int interations = 2;

    [Header("����������")]
    [Range(1, 8)]
    public int downSample = 1;

    //����Shader��ֵ��

    [Header("����������ֵ")]
    [Range(0.0f, 4.0f)]
    public float luminanceThreshold = 0.6f;

    [Header("ģ�����ĵ�")]
    [Range(0.0f, 1.0f)]
    public float[] lightPosInScreenUV = new float[2]{ 0.5f, 0.5f };

    [Header("ģ���뾶")]
    [Range(0.0f, 10.0f)]
    public float lightRadius = 0.5f;

    [Header("����pow")]
    [Range(0.0f, 40.0f)]
    public float factorPow = 1;

    [Header("���������")]
    [Range(1, 20)]
    public int samplePointNum = 10;

    [Header("����ƫ��ֵ")]
    [Range(0.0f, 0.05f)]
    public float sampleOffset = 0.01f;

    [Header("�����ɫ")]
    public Color lightColor = new Color(0.0f, 0.0f, 0.0f, 0.0f);

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (GodRayMaterial != null)
        {
            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            //����rt
            RenderTexture rt0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            rt0.filterMode = FilterMode.Bilinear;

            //Pass1

            GodRayMaterial.SetFloat("_LuminanceThreshold", luminanceThreshold);
            GodRayMaterial.SetColor("_LightPosInScreenUV", new Color(lightPosInScreenUV[0], lightPosInScreenUV[1],0,0));
            GodRayMaterial.SetFloat("_LightRadius", lightRadius);
            GodRayMaterial.SetFloat("_FactorPow", factorPow);

            Graphics.Blit(source, rt0, GodRayMaterial, 0);

            //Pass2

            GodRayMaterial.SetInt("_SamplePointNum", samplePointNum);
            GodRayMaterial.SetFloat("_SampleOffset", sampleOffset);
            GodRayMaterial.SetColor("_LightColor", lightColor);
            for (int i = 0; i < interations; i++)
            {
                RenderTexture rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(rt0, rt1, GodRayMaterial, 1);
                RenderTexture.ReleaseTemporary(rt0);
                rt0 = rt1;
                rt1 = RenderTexture.GetTemporary(rtW, rtH, 0);
            }

            //Pass3

            GodRayMaterial.SetTexture("_RadiusBlur", rt0);
            Graphics.Blit(source, destination, GodRayMaterial, 2);
            RenderTexture.ReleaseTemporary(rt0);
        }
        else
        {
            Debug.Log("Please input your Material");
            Graphics.Blit(source, destination);
        }
    }

}
