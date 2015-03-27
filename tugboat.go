package tugboat

import (
	"code.google.com/p/goauth2/oauth"

	"github.com/google/go-github/github"
	"github.com/joshk/pusher"
	"github.com/mattes/migrate/migrate"
	"golang.org/x/net/context"
)

// BaseURL is the baseURL where tugboat is running.
var BaseURL string

// Config is configuration for a new Tugboat instance.
type Config struct {
	Pusher struct {
		URL string
	}

	GitHub struct {
		Token string
	}

	// DB connection string.
	DB string
}

// Tugboat provides methods for performing deployments.
type Tugboat struct {
	// Provider is a provider that will be used to fullfill deployments.
	Providers []Provider

	store *store

	deployments deploymentsService
	logs        logsService
}

// New returns a new Tugboat instance.
func New(config Config) (*Tugboat, error) {
	db, err := dialDB(config.DB)
	if err != nil {
		return nil, err
	}
	store := &store{db: db}

	pusher, err := newPusherClient(config.Pusher.URL)
	if err != nil {
		return nil, err
	}

	github := newGitHubClient(config.GitHub.Token)

	var updater multiUpdater

	if config.Pusher.URL != "" {
		updater = append(updater, &pusherUpdater{
			pusher: pusher,
		})
	}

	if config.GitHub.Token != "" {
		updater = append(updater, &githubUpdater{
			github: github.Repositories,
		})
	}

	deployments := newDeploymentsService(store, updater)
	logs := newLogsService(store, pusher)

	return &Tugboat{
		store:       store,
		deployments: deployments,
		logs:        logs,
	}, nil
}

func (t *Tugboat) DeploymentsRecent() ([]*Deployment, error) {
	return t.store.DeploymentsRecent()
}

func (t *Tugboat) DeploymentsFind(id string) (*Deployment, error) {
	return t.store.DeploymentsFind(id)
}

func (t *Tugboat) Logs(d *Deployment) (string, error) {
	lines, err := t.store.LogLines(d)
	if err != nil {
		return "", err
	}

	out := ""
	for _, line := range lines {
		out += line.Text
	}

	return out, nil
}

// Deploy triggers a new deployment.
func (t *Tugboat) Deploy(ctx context.Context, opts DeployOpts) ([]*Deployment, error) {
	ps := t.Providers
	if len(ps) == 0 {
		ps = []Provider{&NullProvider{}}
	}

	var deployments []*Deployment

	for _, p := range ps {
		d, err := t.deploy(ctx, opts, p)
		if err != nil {
			return nil, err
		}

		deployments = append(deployments, d)
	}

	return deployments, nil
}

func (t *Tugboat) deploy(ctx context.Context, opts DeployOpts, p Provider) (*Deployment, error) {
	d := newDeployment(opts)
	d.Started(p.Name())

	if err := t.deployments.DeploymentsCreate(d); err != nil {
		return d, err
	}

	go func() {
		w := &logWriter{
			createLogLine: t.logs.LogLinesCreate,
			deploymentID:  d.ID,
		}

		deploy(ctx, d, w, p)

		t.deployments.DeploymentsUpdate(d)
	}()

	return d, nil
}

func (t *Tugboat) Reset() error {
	return t.store.Reset()
}

// Migrate runs the migrations.
func Migrate(db, path string) ([]error, bool) {
	return migrate.UpSync(db, path)
}

func newPusherClient(uri string) (Pusher, error) {
	if uri == "" {
		return &nullPusher{}, nil
	}

	c, err := ParsePusherCredentials(uri)
	if err != nil {
		return nil, err
	}

	return newAsyncPusher(
		pusher.NewClient(c.AppID, c.Key, c.Secret),
		1000,
	), nil
}

func newGitHubClient(token string) *github.Client {
	t := &oauth.Transport{
		Token: &oauth.Token{AccessToken: token},
	}

	return github.NewClient(t.Client())
}
