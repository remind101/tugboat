@vcr @dev
Feature: Deploying via the api

    Shipr can automatically setup a repo for GitHub deployments

    Scenario: Deploying
        When I deploy "shipr-test/test-repo" with:
            | ref | master |
