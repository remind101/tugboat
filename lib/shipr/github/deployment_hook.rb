module Shipr
  module GitHub
    class DeploymentHook
      attr_reader :repo

      def initialize(repo)
        @repo = repo
      end

      def self.install(*args)
        new(*args).install
      end

      def install
        fetch || create
      end

      def fetch
        hooks.find { |hook| hook['name'] == name.to_s && hook['config']['url'] == url }
      end

      def create
        client.create_hook(repo, configuration)
      end

    private

      def hooks
        client.get_hooks(repo).body
      end

      def configuration
        { name: name,
          events: [:deployment],
          active: true,
          config: {
            url: url,
            content_type: 'json'
          } }
      end

      def name
        :web
      end

      def url
        Shipr.configuration.github_hook
      end

      def client
        Shipr.github
      end
    end
  end
end
