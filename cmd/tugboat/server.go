package main

import (
	"fmt"
	"log"
	"net/http"
	"net/url"

	"github.com/codegangsta/cli"
	"github.com/remind101/tugboat"
	"github.com/remind101/tugboat/notifier"
	"github.com/remind101/tugboat/notifier/slack"
	"github.com/remind101/tugboat/server"
)

var cmdServer = cli.Command{
	Name:      "server",
	ShortName: "s",
	Usage:     "Run the tugboat server.",
	Action:    runServer,
	Flags: []cli.Flag{
		flagDB,
		cli.StringFlag{
			Name:   "base.url",
			Value:  "http://localhost:8080",
			Usage:  "The base url where tugboat is running.",
			EnvVar: "TUGBOAT_BASE_URL",
		},
		cli.StringFlag{
			Name:   "port",
			Value:  "8080",
			Usage:  "The port to run the server on.",
			EnvVar: "PORT",
		},
		cli.StringFlag{
			Name:   "pusher.url",
			Value:  "",
			Usage:  "A Pusher connection string.",
			EnvVar: "TUGBOAT_PUSHER_URL",
		},
		cli.StringFlag{
			Name:   "provider",
			Value:  "",
			Usage:  "A comma delimited list of providers to deploy to.",
			EnvVar: "TUGBOAT_PROVIDERS",
		},
		cli.StringFlag{
			Name:   "github.token",
			Value:  "",
			Usage:  "A GitHub API token for creating deployment statuses.",
			EnvVar: "TUGBOAT_GITHUB_TOKEN",
		},
		cli.StringFlag{
			Name:   "github.secret",
			Value:  "",
			Usage:  "A shared secret between tugboat and github used to sign and verify webhooks.",
			EnvVar: "TUGBOAT_GITHUB_SECRET",
		},
		cli.StringFlag{
			Name:   "github.client_id",
			Value:  "",
			Usage:  "OAuth client id.",
			EnvVar: "TUGBOAT_GITHUB_CLIENT_ID",
		},
		cli.StringFlag{
			Name:   "github.client_secret",
			Value:  "",
			Usage:  "OAuth client secret.",
			EnvVar: "TUGBOAT_GITHUB_CLIENT_SECRET",
		},
		cli.StringFlag{
			Name:   "github.organization",
			Value:  "",
			Usage:  "If provided, specifies the github organization that users need to be a member of to authenticate.",
			EnvVar: "TUGBOAT_GITHUB_ORG",
		},
		cli.StringFlag{
			Name:   "cookie.secret",
			Value:  "",
			Usage:  "A secret key used to sign cookies. Should be 32 characters long.",
			EnvVar: "TUGBOAT_COOKIE_SECRET",
		},

		cli.StringFlag{
			Name:   "notifier",
			Value:  "",
			Usage:  "A notifier to use to handle deployment status webhooks.",
			EnvVar: "TUGBOAT_NOTIFIER",
		},
	},
}

func runServer(c *cli.Context) {
	tugboat.BaseURL = c.String("base.url")

	port := c.String("port")

	tug, err := newTugboat(c)
	if err != nil {
		log.Fatal(err)
	}

	n, err := newNotifier(c.String("notifier"))
	if err != nil {
		log.Fatal(err)
	}

	s := newServer(tug, n, c)

	log.Printf("Starting on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, s))
}

func newServer(tug *tugboat.Tugboat, notifier notifier.Notifier, c *cli.Context) http.Handler {
	config := server.Config{}
	config.GitHub.Secret = c.String("github.secret")
	config.GitHub.ClientID = c.String("github.client_id")
	config.GitHub.ClientSecret = c.String("github.client_secret")
	config.GitHub.Organization = c.String("github.organization")
	config.CookieSecret = readKey(c.String("cookie.secret"))

	cd, err := tugboat.ParsePusherCredentials(c.String("pusher.url"))
	if err != nil {
		log.Fatal(err)
	}
	config.Pusher.Key = cd.Key
	config.Pusher.Secret = cd.Secret

	return server.New(tug, notifier, config)
}

func newNotifier(uri string) (notifier.Notifier, error) {
	if uri == "" {
		return &notifier.NullNotifier{}, nil
	}

	u, err := url.Parse(uri)
	if err != nil {
		return nil, err
	}

	switch {
	case u.Host == "hooks.slack.com":
		return slack.New(u.String()), nil
	default:
		return nil, fmt.Errorf("no notifier: %s", u.Scheme)
	}
}

func readKey(secret string) [32]byte {
	var key [32]byte

	max := 32
	if len(secret) < max {
		max = len(secret)
	}

	for i := 0; i < max; i++ {
		key[i] = secret[i]
	}

	return key
}
