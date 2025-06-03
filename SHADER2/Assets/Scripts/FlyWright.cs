using System.Collections.Generic;
using UnityEngine;

public class MaterialFlyweightFactory
{
    private Dictionary<string, MaterialFlyweight> _materials = new Dictionary<string, MaterialFlyweight>();

    public MaterialFlyweight GetMaterial(string key, Texture2D texture, Color baseColor)
    {
        if (!_materials.ContainsKey(key))
        {
            _materials[key] = new MaterialFlyweight(texture, baseColor);
        }
        return _materials[key];
    }
}

public class MaterialFlyweight
{
    public Texture2D Texture { get; }  // 共享的贴图
    public Color BaseColor { get; }   // 共享的基础颜色

    public MaterialFlyweight(Texture2D texture, Color baseColor)
    {
        Texture = texture;
        BaseColor = baseColor;
    }
}