package github_test

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"net/http/httptest"
	"os"
	"testing"
	"time"

	"github.com/remind101/tugboat"
	"github.com/remind101/tugboat/notifier"
	"github.com/remind101/tugboat/pkg/hooker"
	"github.com/remind101/tugboat/provider/fake"
	"github.com/remind101/tugboat/server"
)

func TestDeployment(t *testing.T) {
	c, tug, s := NewTestClient(t)
	defer s.Close()

	raw := deploymentPayload(t, "ok")
	_, err := c.Trigger("deployment", bytes.NewReader(raw))
	if err != nil {
		t.Fatal(err)
	}

	ch := make(chan *tugboat.Deployment)

	go func() {
		for {
			<-time.After(1 * time.Second)

			ds, err := tug.DeploymentsRecent()
			if err != nil {
				t.Fatal(err)
			}

			if len(ds) != 0 {
				d := ds[0]

				t.Logf("Status: %s", d.Status)

				if d.Status == tugboat.StatusSucceeded {
					ch <- d
					break
				}
			}
		}
	}()

	select {
	case d := <-ch:
		out, err := tug.Logs(d)
		if err != nil {
			t.Fatal(err)
		}

		if got, want := out, fake.DefaultScenarios["Ok"].Logs; got != want {
			t.Fatalf("Logs => %s; want %s", got, want)
		}
	case <-time.After(2 * time.Second):
		t.Fatal("timedout")
	}
}

// NewTestClient will return a new heroku.Client that's configured to interact
// with a instance of the empire HTTP server.
func NewTestClient(t testing.TB) (*hooker.Client, *tugboat.Tugboat, *httptest.Server) {
	config := tugboat.Config{}
	config.DB = "postgres://localhost/tugboat?sslmode=disable"
	config.GitHub.Token = os.Getenv("TUGBOAT_GITHUB_TOKEN")

	tug, err := tugboat.New(config)
	if err != nil {
		t.Fatal(err)
	}
	tug.Providers = []tugboat.Provider{fake.NewProvider()}

	if err := tug.Reset(); err != nil {
		t.Fatal(err)
	}

	s := httptest.NewServer(server.New(tug, &notifier.NullNotifier{}, server.Config{}))
	c := hooker.NewClient(nil)
	c.URL = s.URL

	return c, tug, s
}

func deploymentPayload(t testing.TB, fixture string) []byte {
	raw, err := ioutil.ReadFile(fmt.Sprintf("test-fixtures/deployment/%s.json", fixture))
	if err != nil {
		t.Fatal(err)
	}

	return raw
}
