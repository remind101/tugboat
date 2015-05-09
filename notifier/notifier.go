package notifier

// The github deployment states as defined in
// https://developer.github.com/v3/repos/deployments/#list-deployment-statuses
const (
	StatusPending = "pending"
	StatusSuccess = "success"
	StatusError   = "error"
	StatusFailure = "failure"
)

// Notification is passed to notifiers.
type Notification struct {
	// The ID of the deployment.
	ID int64

	// URL to view this deployment.
	TargetURL string

	// The state being transitioned to.
	State string

	// The description provided when the deployment status was created.
	Description string

	// The full name of the repo.
	Repo string

	// The username of the user that initiated the deployment.
	User string

	// The git sha for the deployment.
	Sha string

	// The git ref for the deployment.
	Ref string

	// The environment being deployed to.
	Environment string
}

// Notifier is an interface that notifiers can implement.
type Notifier interface {
	Notify(*Notification) error
}

type NotifierFunc func(*Notification) error

func (f NotifierFunc) Notify(n *Notification) error {
	return f(n)
}

// NullNotifier is an implementation of the Notifier interface that does nothing.
type NullNotifier struct{}

// Notify does nothing.
func (n *NullNotifier) Notify(note *Notification) error {
	return nil
}

// MultiNotifier wraps a collection of Notifier's as a single notifier.
type MultiNotifier []Notifier

// Notify implements the Notifier interface.
func (mn MultiNotifier) Notify(note *Notification) error {
	for _, n := range mn {
		if err := n.Notify(note); err != nil {
			return err
		}
	}

	return nil
}

// FilterState wraps a notifier to only be called if the notification state
// matches state.
func FilterState(state string, n Notifier) Notifier {
	return NotifierFunc(func(p *Notification) error {
		if p.State == state {
			return n.Notify(p)
		}

		return nil
	})
}
