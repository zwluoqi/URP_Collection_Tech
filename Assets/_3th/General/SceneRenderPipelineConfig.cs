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
        GraphicsSettings.renderPipelineAsset = renderPipelineAsset;
        Lightmapping.lightingSettings = lightingSettingsAsset;
        RenderSettings.skybox = skyBoxAsset;
    }

    void OnValidate()
    {
        GraphicsSettings.renderPipelineAsset = renderPipelineAsset;
    }
}
