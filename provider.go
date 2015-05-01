package tugboat

import (
	"errors"
	"fmt"
	"io"

	"github.com/remind101/tugboat/config"
	"golang.org/x/net/context"
)

var (
	// ErrFailed can be used by providers to indicate that the deployment
	// failed.
	ErrFailed = errors.New("deployment failed")
)

// Provider is something that's capable of generating a Deployer.
type Provider interface {
	// Name should return the name of this provider.
	Name() string

	// Generate generates a new Deployer given a config.
	Generate(*Deployment, *config.Config) Deployer
}

// Provider is something that's capable of fullfilling a deployment.
type Deployer interface {
	// Deploy should perform the deployment. An io.Writer can be provided
	// for providers to write log output to. If the deployment failed
	// without a specific error, and the user should view the logs to find
	// out why, then an ErrFailed should be returned.
	Deploy(context.Context, *Deployment, io.Writer) error
}

type DeployerFunc func(context.Context, *Deployment, io.Writer) error

func (f DeployerFunc) Deploy(ctx context.Context, d *Deployment, w io.Writer) error {
	return f(ctx, d, w)
}

func (f DeployerFunc) Name() string {
	return fmt.Sprintf("func: %v", f)
}

var _ Provider = &NullProvider{}

// NullProvider is a Provider that does nothing.
type NullProvider struct{}

func (p *NullProvider) Name() string {
	return "null"
}

func (p *NullProvider) Generate(d *Deployment, c *config.Config) Deployer {
	return DeployerFunc(func(ctx context.Context, d *Deployment, w io.Writer) error {
		return nil
	})
}
