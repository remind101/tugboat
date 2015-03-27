package slack

import (
	"testing"

	"github.com/remind101/tugboat/notifier"
)

// fakeClient is an implementation of the Client interface that stores the payload for
// inspection.
type fakeClient struct {
	payload *Payload
}

func (c *fakeClient) Notify(p *Payload) error {
	c.payload = p
	return nil
}

func TestNotify(t *testing.T) {
	client := &fakeClient{}
	n := &Notifier{client: client}
	p := &notifier.Notification{
		ID:          1,
		TargetURL:   "http://tugboat.example.org/1234",
		State:       "pending",
		Repo:        "ejholmes/acme-inc",
		User:        "ejholmes",
		Sha:         "208db1b5d2bb89b0ff0b79cb7f702e21a750f3fc",
		Ref:         "master",
		Environment: "staging",
	}

	tests := []struct {
		state    string
		expected string
	}{
		{"pending", "Deploy <http://tugboat.example.org/1234|#1> (<https://github.com/ejholmes/acme-inc/commits/208db1b5d2bb89b0ff0b79cb7f702e21a750f3fc|208db1b>) of ejholmes/acme-inc@master to staging by ejholmes started"},
		{"success", "Deploy <http://tugboat.example.org/1234|#1> (<https://github.com/ejholmes/acme-inc/commits/208db1b5d2bb89b0ff0b79cb7f702e21a750f3fc|208db1b>) of ejholmes/acme-inc@master to staging by ejholmes succeeded"},
		{"failure", "Deploy <http://tugboat.example.org/1234|#1> (<https://github.com/ejholmes/acme-inc/commits/208db1b5d2bb89b0ff0b79cb7f702e21a750f3fc|208db1b>) of ejholmes/acme-inc@master to staging by ejholmes failed"},
		{"error", "Deploy <http://tugboat.example.org/1234|#1> (<https://github.com/ejholmes/acme-inc/commits/208db1b5d2bb89b0ff0b79cb7f702e21a750f3fc|208db1b>) of ejholmes/acme-inc@master to staging by ejholmes errored"},
	}

	for i, tt := range tests {
		p.State = tt.state

		err := n.Notify(p)
		if err != nil {
			t.Error(err)
		}

		if client.payload == nil {
			t.Errorf("%v: Expected a payload to be sent to slack", i)
			break
		}

		if got, want := client.payload.Attachments[0].Text, tt.expected; got != want {
			t.Errorf("Text => %q; want %q", got, want)
		}
	}
}
