package newrelic

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"github.com/remind101/tugboat/notifier"
)

const DefaultURL = "https://api.newrelic.com/deployments.xml"

var _ notifier.Notifier = &Notifier{}

type DeploymentForm struct {
	Deployment struct {
		AppName     string `json:"app_name"`
		Description string `json:"description"`
		Revision    string `json:"revision"`
		Changelog   string `json:"changelog"`
		User        string `json:"user"`
	} `json:"deployment"`
}

// Notifier is a Notifier implementation that tracks deployment events in New
// Relic.
type Notifier struct {
	// Key is the new relic API key.
	Key string

	// The URL to POST deployments to. Zero value is DefaultURL.
	URL string

	client *http.Client
}

func (n *Notifier) Notify(p *notifier.Notification) error {
	// Only create deployments if it's successful.
	if p.State != notifier.StatusSuccess {
		return nil
	}

	var data DeploymentForm
	data.Deployment.AppName = appName(p)
	data.Deployment.Revision = p.Sha
	data.Deployment.User = p.User

	raw, err := json.Marshal(&data)
	if err != nil {
		return err
	}

	url := n.URL
	if url == "" {
		url = DefaultURL
	}

	req, err := http.NewRequest("POST", url, bytes.NewReader(raw))
	if err != nil {
		return err
	}

	req.Header.Set("X-API-Key", n.Key)
	req.Header.Set("Content-Type", "application/json")

	c := n.client
	if c == nil {
		c = http.DefaultClient
	}

	_, err = c.Do(req)
	if err != nil {
		return err
	}

	return nil
}

func appName(p *notifier.Notification) string {
	parts := strings.Split(p.Repo, "/")
	app := parts[1]

	env := p.Environment
	if env == "production" {
		env = "prod"
	}

	return fmt.Sprintf("%s-%s", app, env)
}
