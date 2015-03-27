package slack

import "github.com/remind101/tugboat/notifier"

// Convenience colors.
const (
	Yellow = "#ff0"
	Green  = "#0f0"
	Red    = "#f00"
)

// Templates are the templates to be used when sending Slack messages.
var Templates = map[string]*Template{
	"pending": templatePending,
	"success": templateSuccess,
	"failure": templateFailure,
	"error":   templateError,
}

// Notifier is an implementation of the tugboat.Notifier interface
// that forwards deployment core events to Slack.
type Notifier struct {
	client interface {
		Notify(*Payload) error
	}
}

// New returns a new Notifier instance and configures a slack client.
func New(url string) *Notifier {
	c := newClient(nil)
	c.URL = url

	return &Notifier{
		client: c,
	}
}

// Notify sends a notification to Slack.
func (n *Notifier) Notify(p *notifier.Notification) error {
	t := Templates[p.State]

	text, err := t.Render(p)
	if err != nil {
		return err
	}

	return n.client.Notify(&Payload{
		Attachments: []*Attachment{
			&Attachment{
				Text:     text,
				Fallback: text,
				Color:    t.Color,
			},
		},
	})
}
