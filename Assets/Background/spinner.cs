using UnityEngine;
using System.Collections;

public class spinner : MonoBehaviour {
	public float m_Speed = 2f;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		this.transform.Rotate (new Vector3 (0f, m_Speed, 0f));
	}
}
