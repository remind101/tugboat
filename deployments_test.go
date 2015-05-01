package tugboat

import (
	"errors"
	"io"
	"io/ioutil"
	"testing"

	"golang.org/x/net/context"
)

func TestDeploy(t *testing.T) {
	tests := []struct {
		fn     DeployerFunc
		status DeploymentStatus
		err    string
	}{
		{
			fn: func(ctx context.Context, d *Deployment, w io.Writer) error {
				return nil
			},
			status: StatusSucceeded,
		},
		{
			fn: func(ctx context.Context, d *Deployment, w io.Writer) error {
				return ErrFailed
			},
			status: StatusFailed,
		},
		{
			fn: func(ctx context.Context, d *Deployment, w io.Writer) error {
				return errors.New("boom")
			},
			status: StatusErrored,
			err:    "boom",
		},
		{
			fn: func(ctx context.Context, d *Deployment, w io.Writer) error {
				panic("boom")
			},
			status: StatusErrored,
			err:    "boom",
		},
		{
			fn: func(ctx context.Context, d *Deployment, w io.Writer) error {
				panic(errors.New("boom"))
			},
			status: StatusErrored,
			err:    "boom",
		},
	}

	for i, tt := range tests {
		d := &Deployment{}
		w := ioutil.Discard

		deploy(context.Background(), d, w, tt.fn)

		if got, want := d.Status, tt.status; got != want {
			t.Fatalf("#%d: Status => %s; want %s", i, got, want)
		}

		if got, want := d.Error, tt.err; got != want {
			t.Fatalf("Error => %s; want %s", got, want)
		}
	}
}

func TestDeploymentStarted(t *testing.T) {
	d := &Deployment{}
	d.Started("fake")

	if got, want := d.Status, StatusStarted; got != want {
		t.Fatalf("Status => %s; want %s", got, want)
	}

	if got, want := d.Provider, "fake"; got != want {
		t.Fatalf("Provider => %s; want %s", got, want)
	}

	if d.StartedAt == nil {
		t.Fatalf("expected StartedAt to not be nil")
	}
}

func TestDeploymentFailed(t *testing.T) {
	d := &Deployment{Status: StatusPending}
	d.Failed()

	if got, want := d.Status, StatusFailed; got != want {
		t.Fatalf("Status => %s; want %s", got, want)
	}

	if got, want := d.prevStatus, StatusPending; got != want {
		t.Fatalf("prevStatus => %s; want %s", got, want)
	}

	if d.CompletedAt == nil {
		t.Fatalf("expected CompletedAt to not be nil")
	}
}

func TestDeploymentSucceeded(t *testing.T) {
	d := &Deployment{Status: StatusPending}
	d.Succeeded()

	if got, want := d.Status, StatusSucceeded; got != want {
		t.Fatalf("Status => %s; want %s", got, want)
	}

	if got, want := d.prevStatus, StatusPending; got != want {
		t.Fatalf("prevStatus => %s; want %s", got, want)
	}

	if d.CompletedAt == nil {
		t.Fatalf("expected CompletedAt to not be nil")
	}
}

func TestDeploymentErrored(t *testing.T) {
	d := &Deployment{Status: StatusPending}
	d.Errored(errors.New("boom"))

	if got, want := d.Error, "boom"; got != want {
		t.Fatalf("Error => %s; want %s", got, want)
	}

	if got, want := d.Status, StatusErrored; got != want {
		t.Fatalf("Status => %s; want %s", got, want)
	}

	if got, want := d.prevStatus, StatusPending; got != want {
		t.Fatalf("prevStatus => %s; want %s", got, want)
	}

	if d.CompletedAt == nil {
		t.Fatalf("expected CompletedAt to not be nil")
	}
}
