package main

import "testing"

func TestDiscoverCamera(t *testing.T) {
	s, err := CameraDiscovery()
	if err != nil || len(s) == 0 {
		t.Errorf("Failed to discover camera %s", err)
	}
	t.Log(s[0])
}
