using UnityEngine;
using System.Collections;
using System;

public class flyweightTerrain : MonoBehaviour
{
    public Material redMat;
    public Material greenMat;

    flyweightTile redTile;
    flyweightTile greenTile;
    flyweightTile[,] tiles;
    int width = 5;
    int height = 5;
    int[,] terrain = {
        { 0,1,0,0,0},
        { 0,0,0,1,0},
        { 1,0,0,1,0},
        { 1,0,0,0,0},
        { 0,0,1,0,0}
    };
    void Start()
    {
        redTile = new flyweightTile(redMat, true);
        greenTile = new flyweightTile(greenMat, false);
        drawTerrain();
    }

    void drawTerrain()
    {
        tiles = new flyweightTile[width, height];
        for (int i = 0; i < width; i++)
            for (int j = 0; j < height; j++)
            {
                if (terrain[i, j] == 0)
                    tiles[i, j] = greenTile;
                else
                    tiles[i, j] = redTile;
            }
        for (int i = 0; i < width; i++)
            for (int j = 0; j < height; j++)
            {
                GameObject obj = GameObject.CreatePrimitive(PrimitiveType.Cube);
                obj.transform.position = new Vector3(i - 2, 0, j);
                obj.GetComponent<MeshRenderer>().material = tiles[i, j].mat;
            }

    }
}

class flyweightTile
{
    public flyweightTile(Material mat, bool isHard = false)
    {
        this.mat = mat;
        _ishard = ishard;
    }
    public Material mat;
    bool _ishard = false;
    public bool ishard
    {
        get { return _ishard; }
    }

}
