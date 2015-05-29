package api_test

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/remind101/tugboat"
	"github.com/remind101/tugboat/server"
)

const githubSecret = "abcd"

func TestDeploymentsCreate(t *testing.T) {
	c, _, s := newTestClient(t)
	defer s.Close()

	d, err := createDeployment(c)
	if err != nil {
		t.Fatal(err)
	}

	if got, want := d.Repo, "remind101/acme-inc"; got != want {
		t.Fatalf("Repo => %s; want %s", got, want)
	}

	if got, want := d.Status, tugboat.StatusStarted; got != want {
		t.Fatalf("Status => %s; want %s", got, want)
	}

	if got, want := d.Environment, "production"; got != want {
		t.Fatalf("Environment => %s; want %s", got, want)
	}

	if got, want := d.Provider, "heroku"; got != want {
		t.Fatalf("Provider => %s; want %s", got, want)
	}
}

func TestDeploymentsCreate_Unauthorized(t *testing.T) {
	c, _, s := newTestClient(t)
	defer s.Close()
	c.Token = "Foo"

	if _, err := createDeployment(c); err == nil {
		t.Fatal("Expected request to not be authorized")
	}
}

func TestStreamLogs(t *testing.T) {
	c, tug, s := newTestClient(t)
	defer s.Close()

	d, err := createDeployment(c)
	if err != nil {
		t.Fatal(err)
	}

	logs := `Logs
Are
Awesome!`

	if err := c.WriteLogs(d, strings.NewReader(logs)); err != nil {
		t.Fatal(err)
	}

	got, err := tug.Logs(d)
	if err != nil {
		t.Fatal(err)
	}

	if want := logs; got != want {
		t.Fatalf("Logs => %q; want %q", got, want)
	}
}

func TestUpdateStatus(t *testing.T) {
	c, _, s := newTestClient(t)
	defer s.Close()

	d, err := createDeployment(c)
	if err != nil {
		t.Fatal(err)
	}

	if err := c.UpdateStatus(d, tugboat.StatusUpdate{
		Status: tugboat.StatusSucceeded,
	}); err != nil {
		t.Fatal(err)
	}
}

// createDeployment creates a fake Deployment.
func createDeployment(c *tugboat.Client) (*tugboat.Deployment, error) {
	return c.DeploymentsCreate(tugboat.DeployOpts{
		ID:          354773,
		Sha:         "f6044cf59b8dc26af97e1ebd9b955c39d7baeb74",
		Ref:         "master",
		Environment: "production",
		Description: "Deployment",
		Repo:        "remind101/acme-inc",
		Provider:    "heroku",
	})
}

// newTestClient will return a new heroku.Client that's configured to interact
// with a instance of the empire HTTP server.
func newTestClient(t testing.TB) (*tugboat.Client, *tugboat.Tugboat, *httptest.Server) {
	config := tugboat.Config{}
	config.DB = "postgres://localhost/tugboat?sslmode=disable"

	tug, err := tugboat.New(config)
	if err != nil {
		t.Fatal(err)
	}

	if err := tug.Reset(); err != nil {
		t.Fatal(err)
	}

	s := httptest.NewServer(newServer(tug))
	c := tugboat.NewClient(nil)
	c.URL = s.URL
	c.Token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJQcm92aWRlciI6Imhlcm9rdSJ9.HVBoIvRnGKR87odScLnkFWHi4pvSI8V7LJpjh00njBY"

	return c, tug, s
}

func newServer(tug *tugboat.Tugboat) http.Handler {
	config := server.Config{}
	config.GitHub.Secret = githubSecret
	return server.New(tug, config)
}

func deploymentPayload(t testing.TB, fixture string) []byte {
	raw, err := ioutil.ReadFile(fmt.Sprintf("test-fixtures/%s.json", fixture))
	if err != nil {
		t.Fatal(err)
	}

	return raw
}
