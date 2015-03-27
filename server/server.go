package server

import (
	"net/http"
	"os"

	"github.com/gorilla/mux"
	"github.com/kr/githubauth"
	"github.com/remind101/tugboat"
	"github.com/remind101/tugboat/frontend"
	"github.com/remind101/tugboat/notifier"
	"github.com/remind101/tugboat/server/api"
	"github.com/remind101/tugboat/server/github"
)

type Config struct {
	GitHub struct {
		Secret string
	}

	Pusher struct {
		Key string
	}

	// CookieSecret is a secret key that will be used to sign cookies.
	CookieSecret [32]byte
}

func New(tug *tugboat.Tugboat, notifier notifier.Notifier, config Config) http.Handler {
	r := mux.NewRouter()

	// Mount GitHub webhooks
	g := github.New(tug, notifier, config.GitHub.Secret)
	r.MatcherFunc(githubWebhook).Handler(g)

	// Mount the API.
	a := authenticate(api.New(tug), config.CookieSecret)
	r.Headers("Accept", api.AcceptHeader).Handler(a)

	// Fallback to serving the frontend.
	f := frontend.New("")
	f.PusherKey = config.Pusher.Key
	r.NotFoundHandler = authenticate(f, config.CookieSecret)

	return r
}

// githubWebhook is a mux.MatcherFunc that matches requests that have an
// `X-GitHub-Event` header present.
func githubWebhook(r *http.Request, rm *mux.RouteMatch) bool {
	h := r.Header[http.CanonicalHeaderKey("X-GitHub-Event")]
	return len(h) > 0
}

func authenticate(h http.Handler, key [32]byte) http.Handler {
	keys := []*[32]byte{&key}

	return &githubauth.Handler{
		RequireOrg:   os.Getenv("TUGBOAT_GITHUB_ORG"),
		Keys:         keys,
		ClientID:     os.Getenv("TUGBOAT_GITHUB_CLIENT_ID"),
		ClientSecret: os.Getenv("TUGBOAT_GITHUB_CLIENT_SECRET"),
		Handler:      h,
	}
}
