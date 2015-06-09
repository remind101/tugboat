package github

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"github.com/ejholmes/hookshot"
	"github.com/remind101/tugboat"
	"golang.org/x/net/context"
)

func New(tug *tugboat.Tugboat, secret string) http.Handler {
	r := hookshot.NewRouter()

	r.Handle("ping", http.HandlerFunc(Ping))
	r.Handle("deployment", hookshot.Authorize(&DeploymentHandler{tugboat: tug}, secret))

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
