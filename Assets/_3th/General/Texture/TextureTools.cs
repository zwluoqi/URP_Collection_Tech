using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class TextureTools 
{
    
    /// <summary>
    /// Does asset reimport.
    /// </summary>
    /// <param name="path">Path.</param>
    /// <param name="options">Options.</param>
    public static void DoAssetReimport(string path, ImportAssetOptions options)
    {
        try
        {
            AssetDatabase.StartAssetEditing();
            AssetDatabase.ImportAsset(path, options);
        }
        finally
        {
            AssetDatabase.StopAssetEditing();
        }
    }
    
    /// <summary>
    /// Sets the asset Read/Write enabled state.
    /// </summary>
    /// <returns><c>true</c>, if set read write enabled was asseted, <c>false</c> otherwise.</returns>
    /// <param name="path">Path.</param>
    /// <param name="enabled">If set to <c>true</c> enabled.</param>
    /// <param name="force">If set to <c>true</c> force.</param>
    public static bool AssetSetReadWriteEnabled(string path, bool enabled, bool force)
    {
        if (string.IsNullOrEmpty(path))
            return false;
			
        TextureImporter ti = AssetImporter.GetAtPath(path) as TextureImporter;
			
        if (ti == null)
            return false;
			
        TextureImporterSettings settings = new TextureImporterSettings();
        ti.ReadTextureSettings(settings);
			
        if (force || settings.readable != enabled)
        {
            settings.readable = enabled;
            ti.SetTextureSettings(settings);
            DoAssetReimport(path, ImportAssetOptions.ForceUpdate | ImportAssetOptions.ForceSynchronousImport);
        }
			
        return true;
    }
		
    /// <summary>
    /// Sets the asset texture format.
    /// </summary>
    /// <returns><c>true</c>, if set format was set, <c>false</c> otherwise.</returns>
    /// <param name="path">Path.</param>
    /// <param name="format">Format.</param>
    public static bool AssetSetFormat(string path, TextureImporterFormat format)
    {
        if (string.IsNullOrEmpty(path))
            return false;
			
        TextureImporter ti = AssetImporter.GetAtPath(path) as TextureImporter;
			
        if (ti == null)
            return false;
			
        TextureImporterSettings settings = new TextureImporterSettings();
        ti.ReadTextureSettings(settings);

        if (format != settings.textureFormat) {
            settings.textureFormat = format;


            ti.SetTextureSettings (settings);
            DoAssetReimport (path, ImportAssetOptions.ForceUpdate | ImportAssetOptions.ForceSynchronousImport);
        }
        return true;
    }
    
    /// <summary>
    /// Sets the asset texture format.
    /// </summary>
    /// <returns><c>true</c>, if set format was set, <c>false</c> otherwise.</returns>
    /// <param name="path">Path.</param>
    /// <param name="format">Format.</param>
    public static bool AssetSetCompresss(string path, TextureImporterCompression compress)
    {
        if (string.IsNullOrEmpty(path))
            return false;

        TextureImporter ti = AssetImporter.GetAtPath(path) as TextureImporter;

        if (ti == null)
            return false;

        TextureImporterSettings settings = new TextureImporterSettings();
        ti.ReadTextureSettings(settings);
        TextureImporterPlatformSettings pa = ti.GetDefaultPlatformTextureSettings ();

        pa.textureCompression = compress;

        ti.SetPlatformTextureSettings(pa);
        ti.SetTextureSettings(settings);
        DoAssetReimport(path, ImportAssetOptions.ForceUpdate | ImportAssetOptions.ForceSynchronousImport);

        return true;
    }
}
