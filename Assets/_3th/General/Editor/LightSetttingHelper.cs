using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class LightSetttingHelper 
{

    [MenuItem("Assets/Create Light Probe")]
    public static void CreateLightProbe()
    {
        AssetDatabase.CreateAsset(Object.Instantiate(LightmapSettings.lightProbes), "Assets/lightProbe.asset");
        
    }
}
