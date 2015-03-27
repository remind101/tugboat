package api

import (
	"net/http"

	"github.com/gorilla/mux"
	"github.com/remind101/tugboat"
)

const AcceptHeader = "application/vnd.tugboat+json; version=1"

func New(t *tugboat.Tugboat) http.Handler {
	r := mux.NewRouter()

	r.Handle("/jobs", &DeploymentsHandler{t}).Methods("GET")
	r.Handle("/jobs/{id}", &DeploymentHandler{t}).Methods("GET")

	return r
}
