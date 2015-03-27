package github

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"github.com/ejholmes/hookshot"
	"github.com/remind101/tugboat"
	"github.com/remind101/tugboat/notifier"
	"golang.org/x/net/context"
)

func New(tug *tugboat.Tugboat, notifier notifier.Notifier, secret string) http.Handler {
	r := hookshot.NewRouter()

	r.Handle("ping", http.HandlerFunc(Ping))
	r.Handle("deployment", hookshot.Authorize(&DeploymentHandler{tugboat: tug}, secret))
	r.Handle("deployment_status", hookshot.Authorize(&DeploymentStatusHandler{notifier: notifier}, secret))

	return r
}

func Ping(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "Ok\n")
}

type Repository struct {
	FullName string `json:"full_name"`
}

type Deployment struct {
	ID          int64                  `json:"id"`
	Sha         string                 `json:"sha"`
	Ref         string                 `json:"ref"`
	Task        string                 `json:"task"`
	Environment string                 `json:"environment"`
	Payload     map[string]interface{} `json:"payload"`
	Description string
	Creator     struct {
		Login string `json:"login"`
	} `json:"creator"`
}

// DeploymentPayload is the webhook payload for a deployment event.
type DeploymentPayload struct {
	Deployment Deployment `json:"deployment"`
	Repository Repository `json:"repository"`
}

type DeploymentHandler struct {
	tugboat *tugboat.Tugboat
}

func (h *DeploymentHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	var p DeploymentPayload

	if err := json.NewDecoder(r.Body).Decode(&p); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	ds, err := h.tugboat.Deploy(context.TODO(), tugboat.DeployOpts{
		ID:          p.Deployment.ID,
		Sha:         p.Deployment.Sha,
		Ref:         p.Deployment.Ref,
		Environment: p.Deployment.Environment,
		Description: p.Deployment.Description,
		Repo:        p.Repository.FullName,
	})
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	for _, d := range ds {
		fmt.Fprintf(w, "Deployment: %s\n", d.ID)
	}
}

type DeploymentStatusPayload struct {
	Deployment       Deployment `json:"deployment"`
	DeploymentStatus struct {
		State       string `json:"state"`
		TargetURL   string `json:"target_url"`
		Description string `json:"description"`
	} `json:"deployment_status"`
	Repository Repository `json:"repository"`
}

type DeploymentStatusHandler struct {
	notifier notifier.Notifier
}

func (h *DeploymentStatusHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	var p DeploymentStatusPayload

	if err := json.NewDecoder(r.Body).Decode(&p); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// For now, if a "user" is provided in the payload use that instead of
	// the github creator.
	user := p.Deployment.Creator.Login
	if u, ok := p.Deployment.Payload["user"].(string); ok {
		user = u
	}

	if err := h.notifier.Notify(&notifier.Notification{
		ID:          p.Deployment.ID,
		TargetURL:   p.DeploymentStatus.TargetURL,
		State:       p.DeploymentStatus.State,
		Repo:        p.Repository.FullName,
		User:        user,
		Sha:         p.Deployment.Sha,
		Ref:         p.Deployment.Ref,
		Environment: p.Deployment.Environment,
	}); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	io.WriteString(w, "Ok\n")
}
