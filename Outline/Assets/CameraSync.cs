using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CameraSync : MonoBehaviour
{
    private Camera _camera;
    public Camera cameraToSync;

    // Start is called before the first frame update
    void Awake()
    {
        _camera = GetComponent<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        _camera.fieldOfView = cameraToSync.fieldOfView;
        _camera.transform.position = cameraToSync.transform.position;
        _camera.transform.rotation = cameraToSync.transform.rotation;
    }
}
