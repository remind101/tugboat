package empire

import (
	"net/http"

	"github.com/remind101/tugboat/pkg/heroku"
)

type client struct {
	*heroku.Service
}

func newClient(c *http.Client) *client {
	if c == nil {
		c = http.DefaultClient
	}

	return &client{
		Service: heroku.NewService(c),
	}
}

type Image struct {
	Repo string `json:"repo"`
	ID   string `json:"id"`
}

func (c *client) Deploy(image Image) error {
	d := struct {
		Image Image `json:"image"`
	}{
		Image: image,
	}

	return c.Post(nil, "/deploys", &d)
}
