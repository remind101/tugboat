package slack

import (
	"bytes"
	"strings"
	"text/template"

	"github.com/remind101/tugboat/notifier"
)

var (
	templatePending = newTemplate(Yellow, statusText("started"))
	templateSuccess = newTemplate(Green, statusText("succeeded"))
	templateFailure = newTemplate(Red, statusText("failed"))
	templateError   = newTemplate(Red, statusText("errored"))
)

func statusText(status string) string {
	return `Deploy <{{.TargetURL}}|#{{.ID}}> (<https://github.com/{{.Repo}}/commits/{{.Sha}}|{{ truncate .Sha 7 }}>) of {{.Repo}}@{{.Ref}} to {{.Environment}} by {{.User}} ` + status
}

var funcMap = template.FuncMap{
	"truncate": func(text string, sz int) string {
		return text[0:sz]
	},
}

// Template represents a template for a given status update message.
type Template struct {
	Color    string
	Template *template.Template
}

func newTemplate(color, templ string) *Template {
	return &Template{
		Color:    color,
		Template: template.Must(template.New("template").Funcs(funcMap).Parse(templ)),
	}
}

// Render renders the template.
func (t *Template) Render(p *notifier.Notification) (string, error) {
	var b bytes.Buffer

	if err := t.Template.Execute(&b, p); err != nil {
		return "", err
	}

	return strings.TrimRight(b.String(), "\n"), nil
}
