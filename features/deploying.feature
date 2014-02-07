Feature: Deploying

    Background:
        Given I am api authenticated

    Scenario: Deploying a git repo
        When I deploy the following:
            | repo | git@github.com:ejholmes/shipr-test.git |
        And I authenticate with github
        And I tail the log output
        Then I should see "Deploying master branch to git@github.com:ejholmes/shipr-test.git"
        And I sleep
