module Shipr
  class Configuration
    # The oauth token to use when sending deploy status updates.
    attr_reader :github_deploy_token

    # The github org to use when authenticating users.
    attr_reader :github_organization

    # The ssh key to include in the deploy worker. Use this to be able to clone
    # private github repos and/or push to heroku.
    attr_accessor :ssh_key

    def github_deploy_token
      ENV['GITHUB_DEPLOY_TOKEN']
    end

    def github_organization
      ENV['GITHUB_ORGANIZATION']
    end

    def ssh_key
      ENV['SSH_KEY']
    end
  end
end
