package empire

import (
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"os"
	"time"

	"github.com/remind101/tugboat"
	"github.com/remind101/tugboat/pkg/heroku"
	"golang.org/x/net/context"
)

type Provider struct {
	client *client
}

func NewProvider(url, token string) *Provider {
	c := newClient(&http.Client{
		Transport: newTransport(token),
	})
	c.URL = url

	return &Provider{
		client: c,
	}
}

func (p *Provider) Name() string {
	return "empire"
}

func (p *Provider) Deploy(ctx context.Context, d *tugboat.Deployment, w io.Writer) error {
	io.WriteString(w, "Deploying with empire... ")
	return p.client.Deploy(Image{
		Repo: d.Repo,
		ID:   d.Sha,
	})
}

func newTransport(token string) http.RoundTripper {
	proxy := &http.Transport{
		Proxy: func(_ *http.Request) (*url.URL, error) {
			proxy := os.Getenv("EMPIRE_PROXY")
			if proxy == "" {
				return nil, nil
			}

			fmt.Println("Using proxy", proxy)

			return url.Parse(proxy)
		},
		Dial: (&net.Dialer{
			Timeout:   30 * time.Second,
			KeepAlive: 30 * time.Second,
		}).Dial,
		TLSHandshakeTimeout: 10 * time.Second,
	}

	return &heroku.Transport{
		Password:  token,
		Transport: proxy,
	}
}
