// package config is a Go package for parsing a tugboat.yml file.
package config

import (
	"encoding/json"
	"io"
)

// Environments represents the `environments` key in provider configuration.
type Environments struct {
	match envMatcher
}

type envMatcher func(string) bool

func (e *Environments) Match(env string) bool {
	if e.match != nil {
		return e.match(env)
	}

	return false
}

func (e *Environments) UnmarshalJSON(b []byte) error {
	var i interface{}

	if err := json.Unmarshal(b, &i); err != nil {
		return err
	}

	switch i := i.(type) {
	case string:
		e.match = stringMatcher(i)
	case []string:
		e.match = arrayMatcher(i)
	}

	return nil
}

// stringMatcher returns an envMatcher that returns true if the environment
// matches in.
func stringMatcher(in string) envMatcher {
	return func(env string) bool {
		return in == env
	}
}

// arrayMatcher returns an envMatcher that returns true if the environment
// matches any of in.
func arrayMatcher(in []string) envMatcher {
	return func(env string) bool {
		for _, i := range in {
			if i == env {
				return true
			}
		}

		return false
	}
}

// Config is the Go representation of a tugboat.yml file.
// TODO Eventually this should be decoupled from individual providers so that
// they can register their own configuration.
type Config struct {
	Providers struct {
		Heroku struct {
			// The allowed environments to use this provider.
			Environments Environments `json:"environments"`

			// Maps an environment to an app name.
			Apps map[string]string `json:"apps"`
		} `json:"heroku"`

		Empire struct {
			// The allowed environments to use this provider.
			Environments Environments `json:"environments"`

			// Maps an environment to an empire API endpoint.
			APIs map[string]string `json:"apis"`
		} `json:"empire"`
	} `json:"providers"`
}

// Parse parses a config, in JSON format.
func Parse(r io.Reader) (*Config, error) {
	var c Config

	if err := json.NewDecoder(r).Decode(&c); err != nil {
		return nil, err
	}

	return &c, nil
}
