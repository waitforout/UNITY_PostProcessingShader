using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class edgeDetect : MonoBehaviour
{
    public Material edgeDetectMaterial;
    public Shader edgeDetectShader;
    [Range(0.0f, 1.0f)]
    public float edgesOnly = 0.0f;
    public Color edgeColor = Color.black;
    public Color backgroundColor = Color.white;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(edgeDetectMaterial!=null)
        {
            edgeDetectMaterial.SetFloat("_EdgeOnly", edgesOnly);
            edgeDetectMaterial.SetColor("_EdgeColor", edgeColor);
            edgeDetectMaterial.SetColor("_BackgroundColor", backgroundColor);

            Graphics.Blit(source, destination, edgeDetectMaterial);
        }
        else
        {
            Debug.LogWarning("Please input your Material");
            Graphics.Blit(source, destination);
        }
    }
}
