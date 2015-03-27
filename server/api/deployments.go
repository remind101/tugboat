package api

import (
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/remind101/tugboat"
)

type Deployment struct {
	ID          string `json:"id"`
	GitHubID    int64  `json:"github_id"`
	Repo        string `json:"repo"`
	Sha         string `json:"sha"`
	Ref         string `json:"ref"`
	Environment string `json:"environment"`
	Status      string `json:"status"`
	Output      string `json:"output"`
	Error       string `json:"error"`
	Provider    string `json:"provider"`
}

func newDeployment(d *tugboat.Deployment) *Deployment {
	return &Deployment{
		ID:          d.ID,
		GitHubID:    d.GitHubID,
		Repo:        d.Repo,
		Sha:         d.Sha,
		Ref:         d.Ref,
		Environment: d.Environment,
		Status:      d.Status.String(),
		Error:       d.Error,
		Provider:    d.Provider,
	}
}

func newDeployments(ds []*tugboat.Deployment) []*Deployment {
	deployments := make([]*Deployment, len(ds))

	for i := 0; i < len(ds); i++ {
		deployments[i] = newDeployment(ds[i])
	}

	return deployments
}

type DeploymentsHandler struct {
	tugboat *tugboat.Tugboat
}

func (h *DeploymentsHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	d, err := h.tugboat.DeploymentsRecent()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(newDeployments(d))
}

type DeploymentHandler struct {
	tugboat *tugboat.Tugboat
}

func (h *DeploymentHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	d, err := h.tugboat.DeploymentsFind(mux.Vars(r)["id"])
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	out, err := h.tugboat.Logs(d)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	res := newDeployment(d)
	res.Output = out

	json.NewEncoder(w).Encode(res)
}
