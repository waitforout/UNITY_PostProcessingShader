using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class BrightnessSaturationAndContrast : MonoBehaviour
{
    public Shader briSatConShader;
    public Material briSatConMaterial;

    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;

    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;

    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f;



    //тксц OnRenderImage(src, des)
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (briSatConMaterial != null)
        {
            briSatConMaterial.SetFloat("_Brightness", brightness);
            briSatConMaterial.SetFloat("_Saturation", saturation);
            briSatConMaterial.SetFloat("_Contrast", contrast);
            Graphics.Blit(source, destination, briSatConMaterial);
        }
        else
        {
            Debug.LogWarning("Please input your Material!");
            Graphics.Blit(source, destination);
        }

    }
}
