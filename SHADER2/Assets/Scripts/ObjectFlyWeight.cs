using UnityEngine;

public class ObjectFlyWeight : MonoBehaviour
{
    private MaterialFlyweight _material;
    private Vector3 _position;
    private Quaternion _rotation;

    // ��ʼ�����������ⲿ���ã�
    public void Initialize(MaterialFlyweight material, Vector3 pos, Quaternion rot)
    {
        _material = material;
        _position = pos;
        _rotation = rot;
    }

    void Update()
    {
        // ÿ֡����λ�ú���ת
        transform.position = _position;
        transform.rotation = _rotation;
    }
}