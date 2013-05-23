# Heroku Deployer

Rest API for deploying git repositories. You give it a path to a git repo
and an environment to deploy to and it will clone the repo, then run
./script/deploy, passing in the environment as `ENVIRONMENT`.


## Deploy

Deploy a git repo to a heroku app.

**Request**

```yaml
# POST /
Accept: application/json
```

```json
{
  "repo": "git@github.com:org/repo.git",
  "environment": "production"
}
```

**Response**

```json
{
  "id": "Zoph8OoG",
}
```
