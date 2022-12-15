using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class GodRay : MonoBehaviour
{
    public Shader GodRayShader;
    public Material GodRayMaterial;
    [Header("模糊迭代次数")]
    [Range(0, 4)]
    public int interations = 2;

    [Header("降采样次数")]
    [Range(1, 8)]
    public int downSample = 1;

    //传入Shader的值：

    [Header("较亮区域阈值")]
    [Range(0.0f, 4.0f)]
    public float luminanceThreshold = 0.6f;

    [Header("模糊中心点")]
    [Range(0.0f, 1.0f)]
    public float[] lightPosInScreenUV = new float[2]{ 0.5f, 0.5f };

    [Header("模糊半径")]
    [Range(0.0f, 10.0f)]
    public float lightRadius = 0.5f;

    [Header("亮度pow")]
    [Range(0.0f, 40.0f)]
    public float factorPow = 1;

    [Header("采样点个数")]
    [Range(1, 20)]
    public int samplePointNum = 10;

    [Header("采样偏移值")]
    [Range(0.0f, 0.05f)]
    public float sampleOffset = 0.01f;

    [Header("光的颜色")]
    public Color lightColor = new Color(0.0f, 0.0f, 0.0f, 0.0f);

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (GodRayMaterial != null)
        {
            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            //定义rt
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
