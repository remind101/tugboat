# Shipr

Rest API for deploying git repositories. You give it a path to a git repo
and some config vars to set, and it will clone the repo, then run
./script/deploy within that repo, passing along the config vars as environment
variables:

## What happens?

1. You send a post request to `/deploy` with the repo and the config vars.
2. The app spins up a [deploy worker](./workers/deploy.worker) on Iron.io.
3. The worker runs the [deploy script](./bin/deploy), which:
   1. Clones the repo
   2. Checks out the appropriate branch/tag/SHA
   3. Exports your config vars as environment variables
   4. Runs ./script/deploy within the cloned repo.

## Setup

1. Create a heroku app

   ```bash
   $ heroku create
   ```

2. Add an ssh key to the app

   ```bash
   $ heroku config:set SSH_KEY="$(cat ~/.ssh/id_rsa)"
   ```
