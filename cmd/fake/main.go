package main

import (
	"bufio"
	"bytes"
	"flag"
	"io/ioutil"
	"log"
	"os"

	"github.com/remind101/tugboat"
)

var (
	payload = flag.String("payload", "tests/api/test-fixtures/deployment.json", "")
	secret  = flag.String("secret", "", "")
	url     = flag.String("url", "http://localhost:8080", "")
	token   = flag.String("token", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJQcm92aWRlciI6ImZha2UifQ.zmy2Wq7Zbol7N1X-R7WX5R4E2i7uH_Arv7FRR2UwnDE", "")
)

func main() {
	if err := deploy(); err != nil {
		log.Fatal(err)
	}
}

func deploy() error {
	raw, err := ioutil.ReadFile(*payload)
	if err != nil {
		return err
	}

	c := tugboat.NewClient(nil)
	c.URL = *url
	c.Token = *token

	opts, err := tugboat.NewDeployOptsFromReader(bytes.NewReader(raw))
	if err != nil {
		return err
	}
	opts.Provider = "fake"

	d, err := c.DeploymentsCreate(opts)
	if err != nil {
		return err
	}

	if err := c.WriteLogs(d, bufio.NewReader(os.Stdin)); err != nil {
		return err
	}

	if err := c.UpdateStatus(d, tugboat.StatusUpdate{Status: tugboat.StatusSucceeded}); err != nil {
		return err
	}

	return nil
}
