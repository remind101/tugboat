@vcr @dev
Feature: Deploying via the api

    Shipr can automatically setup a repo for GitHub deployments

    Scenario: Deploying
        When I deploy "shipr-test/test-repo"

    Scenario: Deploying when the webhook is already installed
        When I deploy "shipr-test/test-repo"

    Scenario: Deploying an environment
        When I deploy "shipr-test/test-repo" with the payload:
            """
            {"environment":"staging"}
            """
