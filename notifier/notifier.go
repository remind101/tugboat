package notifier

// Notifier is an interface that notifiers can implement.
type Notifier interface {
	Notify(*Notification) error
}

// NullNotifier is an implementation of the Notifier interface that does nothing.
type NullNotifier struct{}

// Notify does nothing.
func (n *NullNotifier) Notify(note *Notification) error {
	return nil
}

// Notification is passed to notifiers.
type Notification struct {
	// The ID of the deployment.
	ID int64

	// URL to view this deployment.
	TargetURL string

	// The state being transitioned to.
	State string

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
