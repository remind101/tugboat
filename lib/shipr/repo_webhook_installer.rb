module Shipr
  class RepoWebhookInstaller
    def initialize(repo)
      @repo = repo
    end

    def self.install(*args)
      new(*args).install
    end

    def install
      client.create_hook repo,
        name: :web,
        events: [:deployment],
        active: true,
        config: {
          url: Shipr.configuration.github_hook,
          content_type: 'json'
        }
    end

    private

    attr_reader :repo

    def client
      Shipr.github
    end
  end
end
