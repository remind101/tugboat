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

## Deploy

Deploy a repo.

**Request**

```yaml
# POST /deploy
Accept: application/json
```

```json
{
  "repo": "git@github.com:org/repo.git",
  "config": {
    "ENVIRONMENT": "production"
  }
}
```

**Response**

```json
{
  "uuid": "d4b1c6e0-a7f6-0130-6f80-0ee966cd821f",
  "repo": "git@github.com:ejholmes/shipr.git",
  "config": {
    "ENVIRONMENT": "production"
  }
}
```
