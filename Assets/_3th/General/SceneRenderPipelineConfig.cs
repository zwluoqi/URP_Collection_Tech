using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class SceneRenderPipelineConfig : MonoBehaviour
{
    public RenderPipelineAsset renderPipelineAsset;
    public LightingSettings lightingSettingsAsset;
    public Material skyBoxAsset;
    void OnEnable()
    {
        if (renderPipelineAsset)
        {
            GraphicsSettings.renderPipelineAsset = renderPipelineAsset;
        }

        if (lightingSettingsAsset)
        {
            Lightmapping.lightingSettings = lightingSettingsAsset;
        }

        if (skyBoxAsset)
        {
            RenderSettings.skybox = skyBoxAsset;
        }
    }

    void OnValidate()
    {
        if (renderPipelineAsset)
        {
            GraphicsSettings.renderPipelineAsset = renderPipelineAsset;
        }

        if (lightingSettingsAsset)
        {
            Lightmapping.lightingSettings = lightingSettingsAsset;
        }

        if (skyBoxAsset)
        {
            RenderSettings.skybox = skyBoxAsset;
        }
    }
}
