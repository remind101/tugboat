// package config is a Go package for parsing a tugboat.yml file.
package config

import (
	"encoding/json"
	"errors"
	"io"
	"net/url"
	"regexp"
)

// Environments represents the `environments` key in provider configuration,
// which controls whether the provider should be used for a specific
// environment.
type Environments struct {
	match envMatcher
}

type envMatcher func(string) bool

// Match returns true if the given env is a match.
func (e *Environments) Match(env string) bool {
	if e.match != nil {
		return e.match(env)
	}

	return false
}

// regexMatch is a regular expression that checks if the given string is a
// regular expression.
//
// For example, "/*/" will match, but "*/" will not.
var regexMatch = regexp.MustCompile(`^/(.*)/$`)

// When provided a string, if the string begins and ends with a forward slash,
// it will parse the regular expression and return it.
func isRegex(s string) (*regexp.Regexp, bool) {
	if !regexMatch.MatchString(s) {
		return nil, false
	}

	r, err := regexp.Compile(regexMatch.ReplaceAllString(s, "$1"))
	if err != nil {
		return nil, false
	}

	return r, true
}

// UnmarshalJSON implements the json.Unmarshaller interface.
func (e *Environments) UnmarshalJSON(b []byte) error {
	var i interface{}

	if err := json.Unmarshal(b, &i); err != nil {
		return err
	}

	switch i := i.(type) {
	case string:
		reg, ok := isRegex(i)
		if ok {
			e.match = regexMatcher(reg)
		} else {
			e.match = stringMatcher(i)
		}
	case []interface{}:
		m, err := newArrayMatcher(i)
		if err != nil {
			return err
		}
		e.match = m
	}

	return nil
}

// regexMatcher returns an envMatcher that matches the environment against the
// given regular expression.
func regexMatcher(in *regexp.Regexp) envMatcher {
	return func(env string) bool {
		return in.MatchString(env)
	}
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

// newArrayMatcher builds an arrayMatcher from a slice of interface{}.
func newArrayMatcher(in []interface{}) (envMatcher, error) {
	var s []string

	for _, i := range in {
		v, ok := i.(string)
		if !ok {
			return nil, errors.New("only strings are allowed")
		}

		s = append(s, v)
	}

	return arrayMatcher(s), nil
}

// Config is the Go representation of a tugboat.yml file.
// TODO Eventually this should be decoupled from individual providers so that
// they can register their own configuration.
type Config struct {
	Providers struct {
		Heroku struct {
			// The allowed environments to use this provider.
			Environments Environments `json:"environments"`
		} `json:"heroku"`

		Empire struct {
			// The allowed environments to use this provider.
			Environments Environments `json:"environments"`

			// Maps an environment to an Empire API.
			APIs map[string]*url.URL `json:"apis"`
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
