Feature: Deploying

    Background:
        Given I am api authenticated

    Scenario: Deploying a git repo
        When I deploy the following:
            | repo | git@github.com:ejholmes/shipr-test.git |
        And I authenticate with github
        And I view the deploy
        Then the deploy should finish
