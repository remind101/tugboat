# Shipr

Shipr is a REST API and AngularJS client for deploying GitHub repositories using the [GitHub deployments api](http://developer.github.com/v3/repos/deployments/).

![](https://s3.amazonaws.com/ejholmes.github.com/Sl3ye.png)

## What happens?

1. You trigger a deploy via github (`POST https://api.github.com/repos/remind101/shipr/deployments`)
2. GitHub sends Shipr a POST request with the deployment event.
2. The app spins up a [deploy worker](./workers/deploy.worker) on Iron.io
3. The worker runs the [deploy script](./bin/deploy), which:
   1. Clones the repository
   2. Checks out the appropriate branch/tag/SHA
   3. Exports your config vars as environment variables
   4. Runs ./script/deploy within the cloned repository

## Why?

The main goal is to make it easier to create tooling for deploying.

## Setup

1. Create a heroku app

   ```bash
   $ heroku create
   ```

2. Add the required addons

   ```bash
   $ heroku addons:add pusher
   $ heroku addons:add cloudamqp
   $ heroku addons:add iron_worker
   $ heroku addons:add mongohq
   ```

3. Update heroku config

   ```bash
   $ heroku config:set RACK_ENV=production
   $ heroku config:set SSH_KEY="$(cat ~/.ssh/id_rsa)"
   $ heroku config:set AUTH_TOKEN="$(pwgen 32 1)"
   $ heroku config:set DOMAIN="<app name>.herokuapp.com"
   $ heroku config:set GITHUB_CLIENT_ID="<client id>"
   $ heroku config:set GITHUB_CLIENT_SECRET="<client secret>"
   $ heroku config:set GITHUB_ORGANIZATION="<github org>"
   $ heroku config:set RABBITMQ_URL="<cloud amqp url>"
   $ heroku config:set RABBITMQ_MANAGEMENT_URL="<cloud amqp management url>"
   ```

4. Deploy the app

   ```bash
   $ export $(heroku config -s | grep IRON)
   $ iron_worker upload workers/deploy
   $ git push heroku master
   ```

## Deploy Script

By default, Shipr will try to run `./script/deploy` inside your repository if
it exists. You can also specify a default script to use if none is provided via
the `DEPLOY_SCRIPT_URL` environment variable. We keep [our default deploy script](https://gist.github.com/ejholmes/474068635673c7f5c413/raw/deploy.sh)
in a gist.

---

Want to work on awesome stuff like this? You should probably [come work with
us](https://www.remind101.com/careers).
