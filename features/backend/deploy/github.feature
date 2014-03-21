@vcr
Feature: Deploying via a GitHub deployment event

    Shipr accepts POST requests for the GitHub `deployment` event

    Scenario: A ping event
        When a ping event is received
        Then the last response should be 200 with the content:
            """
            {}
            """
    
    Scenario: A deployment event
        When a deployment event is received
        Then a job should have been created with:
            | sha         | 5f834de43d24c20ae761f8b4a6fd8a980928b96b |
            | force       | false                                    |
            | environment | production                               |
            | config      | {}                                       |
        And a deploy task should have been created with env:
            | ENVIRONMENT | production                               |
            | FORCE       | 0                                        |
            | REPO        | git@github.com:shipr-test/test-repo.git       |
            | SHA         | 5f834de43d24c20ae761f8b4a6fd8a980928b96b |
