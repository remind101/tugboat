# [Tugboat](https://github.com/ejholmes/tugboat) [![Build Status](https://travis-ci.org/remind101/tugboat.svg?branch=master)](https://travis-ci.org/remind101/tugboat)

Tugboat is an API and AngularJS client for deploying GitHub repos using the [GitHub Deployments API](http://developer.github.com/v3/repos/deployments/).

![](https://s3.amazonaws.com/ejholmes.github.com/ioiPx.png)

## What happens?

1. You trigger a deploy via GitHub (e.g. `POST https://api.github.com/repos/ejholmes/acme-inc/deployments`)
2. GitHub sends Tugboat a POST request with the deployment event.
3. Tugboat deploys the repo using a provider (e.g. To Heroku).

## Why?

The main goal is to make it easier to create tooling for deploying. At [Remind](https://remind.com)
we like to deploy all of our services via Hubot and Slack. If you're using Hubot, you can use
the [hubot-deploy](https://github.com/remind101/hubot-deploy) script or the [deploy CLI](https://github.com/remind101/deploy)
to create GitHub Deployments.

## Providers

Tugboat supports the concept of "provider" backends that control what happens
when Tugboat gets a deployment event from GitHub. Currently, the following
providers are supported.

* **Heroku**: This provider will deploy the repo to Heroku using the [Platform API](https://devcenter.heroku.com/articles/platform-api-reference#build).

## Notifiers

Tugboat can also send notifications to other services to announce information
about a deployment. Currently, the following notifiers are supported.

* **Slack**: Sends notifications about the deployment status to a Slack channel:
  
  ![](https://s3.amazonaws.com/ejholmes.github.com/hpi95.png)

## Setup

**TODO**

## Roadmap

* [Librato annotations notifier](https://github.com/ejholmes/tugboat/issues/7).
* [.tugboat.yml configuration file](https://github.com/ejholmes/tugboat/issues/8).
