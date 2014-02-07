Feature: Deploying

    Background:
        Given I am api authenticated

    Scenario: Deploying a git repo
        When I deploy the following:
            | repo   | https://gist.github.com/8857858.git |
            | script | echo "Deployed repo"                     |
        And I authenticate with github
        And I view the deploy
        Then the repo should eventually be deployed
