# Heroku Deployer

Rest API for deploying git repositories to heroku. You give it a uri to a git
repository, the name of an app, and a heroku api key, and it will deploy the
repo to the app.

## Deploy

Deploy a git repo to a heroku app.

**Request**

```yaml
# POST /?apikey=<heroku api key>
Accept: application/json
```

```json
{
  "repo": "git://:<github token>@github.com/org/repo.git",
  "app": "repo-production"
}
```

**Response**

```json
{
  "id": "Zoph8OoG",
  "stream": "http://heroku-deployer.herokuapp.com/stream/Zoph8OoG"
}
```

You can pass in a url to post the result of the deploy to:

```yaml
# POST /?apikey=<heroku api key>
Accept: application/json
```

```json
{
  "repo": "git@:<github token>@github.com/org/repo.git",
  "app": "repo-production",
  "notify": "http://basic:auth@my-external-app.com/_deploy"
}
```

## Deploy Status

Get the status of a deploy.

**Request**

```yaml
# GET /deploy/:id?apikey=<heroku api key>
```

**Response**

```json
{
  "id": "Zoph8OoG",
  "ok": true,
  "status": "0",
  "stdout": " ... ",
  "stderr": " ... "
}
```
