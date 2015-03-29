package server

import (
	"net/http"
	"os"

	"github.com/gorilla/mux"
	"github.com/kr/githubauth"
	"github.com/remind101/tugboat"
	"github.com/remind101/tugboat/frontend"
	"github.com/remind101/tugboat/notifier"
	"github.com/remind101/tugboat/pkg/pusherauth"
	"github.com/remind101/tugboat/server/api"
	"github.com/remind101/tugboat/server/github"
)

type Config struct {
	GitHub struct {
		Secret string
	}

	Pusher struct {
		Key    string
		Secret string
	}

	// CookieSecret is a secret key that will be used to sign cookies.
	CookieSecret [32]byte
}

func New(tug *tugboat.Tugboat, notifier notifier.Notifier, config Config) http.Handler {
	r := mux.NewRouter()

	// auth is a function that can wrap an http.Handler with authentication.
	auth := authenticate(config.CookieSecret)

	// Mount GitHub webhooks
	g := github.New(tug, notifier, config.GitHub.Secret)
	r.MatcherFunc(githubWebhook).Handler(g)

	// Mount the API.
	a := auth(api.New(tug))
	r.Headers("Accept", api.AcceptHeader).Handler(a)

	// Pusher authentication.
	p := auth(&pusherauth.Handler{
		Key:    config.Pusher.Key,
		Secret: []byte(config.Pusher.Secret),
	})
	r.Handle("/pusher/auth", p)

	// Fallback to serving the frontend.
	f := frontend.New("")
	f.PusherKey = config.Pusher.Key
	r.NotFoundHandler = auth(f)

	return r
}

// githubWebhook is a mux.MatcherFunc that matches requests that have an
// `X-GitHub-Event` header present.
func githubWebhook(r *http.Request, rm *mux.RouteMatch) bool {
	h := r.Header[http.CanonicalHeaderKey("X-GitHub-Event")]
	return len(h) > 0
}

func authenticate(key [32]byte) func(http.Handler) http.Handler {
	keys := []*[32]byte{&key}

	return func(h http.Handler) http.Handler {
		return &githubauth.Handler{
			RequireOrg:   os.Getenv("TUGBOAT_GITHUB_ORG"),
			Keys:         keys,
			ClientID:     os.Getenv("TUGBOAT_GITHUB_CLIENT_ID"),
			ClientSecret: os.Getenv("TUGBOAT_GITHUB_CLIENT_SECRET"),
			Handler:      h,
		}
	}
}
