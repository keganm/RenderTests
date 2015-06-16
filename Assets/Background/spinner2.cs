using UnityEngine;
using System.Collections;

public class spinner2 : MonoBehaviour {
	public float m_Speed = 1.2f;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		this.transform.Rotate (new Vector3 (m_Speed, 0f, 0f));
	}
}
