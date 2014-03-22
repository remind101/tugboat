@vcr
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
    
    @dev
    Scenario: Attempting to deploy a branch that doesn't exist
        When I deploy the "develop" ref of "shipr-test/test-repo"
        Then the last response should be 422 with the content:
            """
            {"message":"No ref found for: develop","documentation_url":"http://developer.github.com/v3"}
            """
