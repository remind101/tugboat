package empire

import (
	"io"
	"net/http"

	"github.com/remind101/tugboat"
	"github.com/remind101/tugboat/pkg/heroku"
	"golang.org/x/net/context"
)

type Provider struct {
	client *client
}

func NewProvider(url, token string) *Provider {
	t := &heroku.Transport{
		Password: token,
	}
	c := newClient(&http.Client{Transport: t})
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
