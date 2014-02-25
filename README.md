# Shipr

Shipr is a rest api and anagularjs client for deploying git repositories. You give it a url to a git repo
and some config vars to set, and it will clone the repo, then run
./script/deploy within that repo, passing along the config vars as environment
variables.

![](https://s3.amazonaws.com/ejholmes.github.com/Sl3ye.png)

## What happens?

1. You send a post request to `/api/deploys` with the repo and the config vars
2. The app spins up a [deploy worker](./workers/deploy.worker) on Iron.io
3. The worker runs the [deploy script](./bin/deploy), which:
   1. Clones the repo
   2. Checks out the appropriate branch/tag/SHA
   3. Exports your config vars as environment variables
   4. Runs ./script/deploy within the cloned repo

## Why?

The main goal is to make it easier to create tooling for deploying. For me,
this means deploying from Hipchat.

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
   ```

4. Deploy the app

   ```bash
   $ export $(heroku config -s | grep IRON)
   $ iron_worker upload workers/deploy
   $ git push heroku master
   $ bundle exec rake db:migrate DATABASE_URL=$(heroku config:get DATABASE_URL)
   ```
