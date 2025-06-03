using UnityEngine;

public class ObjectFlyWeight : MonoBehaviour
{
    private MaterialFlyweight _material;
    private Vector3 _position;
    private Quaternion _rotation;

    // 初始化方法（由外部调用）
    public void Initialize(MaterialFlyweight material, Vector3 pos, Quaternion rot)
    {
        _material = material;
        _position = pos;
        _rotation = rot;
    }

    void Update()
    {
        // 每帧更新位置和旋转
        transform.position = _position;
        transform.rotation = _rotation;
    }
}