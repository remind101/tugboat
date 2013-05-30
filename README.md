# Shipr

Rest API for deploying git repositories. You give it a path to a git repo
and some config vars to set, and it will clone the repo, then run
./script/deploy within that repo, passing along the config vars as environment
variables:

## Deploy

Deploy a repo.

**Request**

```yaml
# POST /
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
