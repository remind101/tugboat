package slack

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
)

// Field represents a field inside an Attachment.
type Field struct {
	Title string `json:"title"`
	Value string `json:"value"`
	Short bool   `json:"short"`
}

// Attachment represents an incoming webhook attachment.
type Attachment struct {
	Fallback string   `json:"fallback"`
	Text     string   `json:"text"`
	PreText  string   `json:"pretext"`
	Color    string   `json:"color"`
	Fields   []*Field `json:"fields,omitempty"`
}

// Payload represents an incoming webhook payload.
type Payload struct {
	Username    string        `json:"username"`
	Text        string        `json:"text"`
	Attachments []*Attachment `json:"attachments,omitempty"`
}

// client is an implementation of the Client interface.
type client struct {
	URL string

	client *http.Client
}

// newClient returns a new client instance.
func newClient(c *http.Client) *client {
	if c == nil {
		c = http.DefaultClient
	}

	return &client{
		client: c,
	}
}

// Notify sends a slack notification.
func (c *client) Notify(p *Payload) error {
	j, err := json.Marshal(p)
	if err != nil {
		return err
	}

	req, err := c.NewRequest("POST", c.URL, j)
	if err != nil {
		return err
	}

	resp, err := c.client.Do(req)
	if err != nil {
		return err
	}

	if resp.StatusCode/100 != 2 {
		return fmt.Errorf("unexpected response: %d", resp.StatusCode)
	}

	return nil
}

func (c *client) NewRequest(method, url string, body []byte) (*http.Request, error) {
	return http.NewRequest(method, url, bytes.NewReader(body))
}
