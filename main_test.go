package main

import (
	"fmt"
	app "github.com/strongjz/go_example_app/app"
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestMain(t *testing.T) {

	app := app.New()

	ts := httptest.NewServer(app.Engine())
	defer ts.Close()
	resp, err := http.Get(fmt.Sprintf("%s/", ts.URL))
	if err != nil {
		t.Fatalf("Expected no error, got %v", err)
	}

	if resp.StatusCode != 200 {
		t.Fatalf("Expected status code 200, got %v", resp.StatusCode)
	}

}
