package config

import (
	"strings"
	"testing"
)

func TestConfig(t *testing.T) {
	tests := []struct {
		in    string
		check func(*Config)
	}{
		{simpleConfig, func(c *Config) {
			if !c.Providers.Heroku.Environments.Match("production") {
				t.Fatal("Expected match")
			}

			if c.Providers.Heroku.Environments.Match("staging") {
				t.Fatal("Expected no match")
			}
		}},
		{arrayEnvironmentsConfig, func(c *Config) {
		}},
	}

	for _, tt := range tests {
		c, err := Parse(strings.NewReader(tt.in))
		if err != nil {
			t.Fatal(err)
		}

		tt.check(c)
	}
}

const simpleConfig = `
{
  "providers": {
    "heroku": {
      "environments": "production",
      "apps": {
        "production": "foo",
	"staging": "bar"
      }
    }
  }
}
`

const arrayEnvironmentsConfig = `
{
  "providers": {
    "heroku": {
      "environments": [
        "production",
	"staging"
      ],
      "apps": {
        "production": "foo",
	"staging": "bar"
      }
    }
  }
}
`
