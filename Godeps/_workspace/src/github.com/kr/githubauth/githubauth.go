package githubauth

import (
	"crypto/rand"
	"encoding/hex"
	"net/http"
	"time"

	"github.com/kr/session"
	"golang.org/x/net/context"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/github"
)

const callbackPath = "/_githubauth"

type Session struct {
	// Client is an HTTP client obtained from oauth2.Config.Client.
	// It adds necessary OAuth2 credentials to outgoing requests to
	// perform GitHub API calls.
	*http.Client
}

type contextKey int

const sessionKey contextKey = 0

// GetSession returns data about the logged-in user
// given the Context provided to a ContextHandler.
func GetSession(ctx context.Context) (*Session, bool) {
	s, ok := ctx.Value(sessionKey).(*Session)
	return s, ok
}

// A ContextHandler can be used as the HTTP handler
// in a Handler value in order to obtain information
// about the logged-in GitHub user through the provided
// Context. See GetSession.
type ContextHandler interface {
	ServeHTTPContext(context.Context, http.ResponseWriter, *http.Request)
}

// Handler is an HTTP handler that requires
// users to log in with GitHub OAuth and requires
// them to be members of the given org.
type Handler struct {
	// RequireOrg is a GitHub organization that
	// users will be required to be in.
	// If unset, any user will be permitted.
	RequireOrg string

	// Used to initialize corresponding fields of a session Config.
	// See github.com/kr/session.
	// If Name is empty, "githubauth" is used.
	Name   string
	Path   string
	Domain string
	MaxAge time.Duration
	Keys   []*[32]byte

	// Used to initialize corresponding fields of oauth2.Config.
	// Scopes can be nil, in which case user:email and read:org
	// will be requested.
	ClientID     string
	ClientSecret string
	Scopes       []string

	// Handler is the HTTP handler called
	// once authentication is complete.
	// If nil, http.DefaultServeMux is used.
	// If the value implements ContextHandler,
	// its ServeHTTPContext method will be called
	// instead of ServeHTTP, and a *Session value
	// can be obtained from GetSession.
	Handler http.Handler
}

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	h.ServeHTTPContext(context.Background(), w, r)
}

func (h *Handler) ServeHTTPContext(ctx context.Context, w http.ResponseWriter, r *http.Request) {
	handler := h.Handler
	if handler == nil {
		handler = http.DefaultServeMux
	}
	if ctx, ok := h.loginOk(ctx, w, r); ok {
		if h2, ok := handler.(ContextHandler); ok {
			h2.ServeHTTPContext(ctx, w, r)
		} else {
			handler.ServeHTTP(w, r)
		}
	}
}

// loginOk checks that the user is logged in and authorized.
// If not, it performs one step of the oauth process.
func (h *Handler) loginOk(ctx context.Context, w http.ResponseWriter, r *http.Request) (context.Context, bool) {
	var user sess
	err := session.Get(r, &user, h.sessionConfig())
	if err != nil && err != http.ErrNoCookie {
		h.deleteCookie(w)
		http.Error(w, "internal error", 500)
		return ctx, false
	}

	redirectURL := "https://" + r.Host + callbackPath
	conf := &oauth2.Config{
		ClientID:     h.ClientID,
		ClientSecret: h.ClientSecret,
		RedirectURL:  redirectURL,
		Scopes:       h.Scopes,
		Endpoint:     github.Endpoint,
	}
	if conf.Scopes == nil {
		conf.Scopes = []string{"user:email", "read:org"}
	}
	if user.OAuthToken != nil {
		session.Set(w, user, h.sessionConfig()) // refresh the cookie
		ctx = context.WithValue(ctx, sessionKey, &Session{
			Client: conf.Client(ctx, user.OAuthToken),
		})
		return ctx, true
	}
	if r.URL.Path == callbackPath {
		if r.FormValue("state") != user.State {
			h.deleteCookie(w)
			http.Error(w, "access forbidden", 401)
			return ctx, false
		}
		tok, err := conf.Exchange(ctx, r.FormValue("code"))
		if err != nil {
			h.deleteCookie(w)
			http.Error(w, "access forbidden", 401)
			return ctx, false
		}
		client := conf.Client(ctx, tok)
		if h.RequireOrg != "" {
			resp, err := client.Head("https://api.github.com/user/memberships/orgs/" + h.RequireOrg)
			if err != nil || resp.StatusCode != 200 {
				h.deleteCookie(w)
				http.Error(w, "access forbidden", 401)
				return ctx, false
			}
		}

		session.Set(w, sess{OAuthToken: tok}, h.sessionConfig())
		http.Redirect(w, r, user.NextURL, http.StatusTemporaryRedirect)
		return ctx, false
	}

	u := *r.URL
	u.Scheme = "https"
	u.Host = r.Host
	state := newState()
	session.Set(w, sess{NextURL: u.String(), State: state}, h.sessionConfig())
	http.Redirect(w, r, conf.AuthCodeURL(state), http.StatusTemporaryRedirect)
	return ctx, false
}

func (h *Handler) sessionConfig() *session.Config {
	c := &session.Config{
		Name:   h.Name,
		Path:   h.Path,
		Domain: h.Domain,
		MaxAge: h.MaxAge,
		Keys:   h.Keys,
	}
	if c.Name == "" {
		c.Name = "githubauth"
	}
	return c
}

func (h *Handler) deleteCookie(w http.ResponseWriter) error {
	conf := h.sessionConfig()
	conf.MaxAge = -1 * time.Second
	return session.Set(w, sess{}, conf)
}

type sess struct {
	OAuthToken *oauth2.Token `json:",omitempty"`
	NextURL    string        `json:",omitempty"`
	State      string        `json:",omitempty"`
}

func newState() string {
	b := make([]byte, 10)
	rand.Read(b)
	return hex.EncodeToString(b)
}
