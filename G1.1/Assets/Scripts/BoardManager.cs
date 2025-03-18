using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoardManager : MonoBehaviour
{
    public int gridWidthSize = 5;
    public int gridHeightSize = 10;// ∆Â≈Ã≥ﬂ¥Á£®¿˝»Á8x8£©
    public GameObject tilePrefab;
    private GameObject[,] grid;

        void Start()
        {
            grid = new GameObject[gridHeightSize, gridWidthSize];
            GenerateBoard();
        }

        void GenerateBoard()
        {
            for (int x = 0; x < gridWidthSize; x++)
            {
                for (int y = 0; y < gridHeightSize; y++)
                {
                    Vector3 pos = new Vector3(x, 0, y); // 3D∆Â≈Ã
                    GameObject tile = Instantiate(tilePrefab, pos, Quaternion.identity);
                    grid[x, y] = tile;
                }
            }
        }
    
}
