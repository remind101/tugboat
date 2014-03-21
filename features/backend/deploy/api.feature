@vcr @dev
Feature: Deploying via the api

    Shipr can automatically setup a repo for GitHub deployments

    Scenario: Deploying
        When I deploy "shipr-test/test-repo" with:
            | ref | master |

    Scenario: Deploying when the webhook is already installed
        When I deploy "shipr-test/test-repo" with:
            | ref | master |
