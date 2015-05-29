package github

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
