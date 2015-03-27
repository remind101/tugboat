package main

import (
	"os"

	"github.com/codegangsta/cli"
	"github.com/remind101/tugboat"
	"github.com/remind101/tugboat/provider/heroku"
)

var commands = []cli.Command{
	cmdServer,
	cmdMigrate,
}

// Shared flags.
var (
	flagDB = cli.StringFlag{
		Name:   "db.url",
		Value:  "postgres://localhost/tugboat?sslmode=disable",
		Usage:  "Postgres connection string.",
		EnvVar: "DATABASE_URL",
	}
)

func main() {
	app := cli.NewApp()
	app.Name = "tugboat"
	app.Commands = commands

	app.Run(os.Args)
}

func newTugboat(c *cli.Context) (*tugboat.Tugboat, error) {
	config := tugboat.Config{}
	config.DB = c.String("db.url")
	config.Pusher.URL = c.String("pusher.url")
	config.GitHub.Token = c.String("github.token")

	tug, err := tugboat.New(config)
	if err != nil {
		return tug, err
	}

	tug.Provider = newProvider(c)

	return tug, nil
}

func newProvider(c *cli.Context) tugboat.Provider {
	return heroku.NewProvider(
		c.String("github.token"),
		c.String("heroku.token"),
	)
}
