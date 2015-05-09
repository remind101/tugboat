package newrelic

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/remind101/tugboat/notifier"
)

func TestNotifier(t *testing.T) {
	var called bool

	s := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		called = true

		if got, want := r.Header.Get("X-API-Key"), "1234"; got != want {
			t.Fatalf("API Key => %s; want %s", got, want)
		}
	}))
	defer s.Close()

	n := &Notifier{URL: s.URL, Key: "1234"}

	if err := n.Notify(&notifier.Notification{
		Repo: "remind101/acme-inc",
	}); err != nil {
		t.Fatal(err)
	}

	if !called {
		t.Fatal("No deployments created")
	}
}

func TestAppName(t *testing.T) {
	tests := []struct {
		in  notifier.Notification
		out string
	}{
		{notifier.Notification{Repo: "remind101/acme-inc", Environment: "production"}, "acme-inc-prod"},
		{notifier.Notification{Repo: "remind101/acme-inc", Environment: "staging"}, "acme-inc-staging"},
		{notifier.Notification{Repo: "remind101/acme-inc", Environment: "other"}, "acme-inc-other"},
	}

	for _, tt := range tests {
		out := appName(&tt.in)

		if got, want := out, tt.out; got != want {
			t.Fatalf("appName => %s; want %s", got, want)
		}
	}
}
