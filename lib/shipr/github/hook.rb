module Shipr
  module GitHub
    class Hook
      attr_reader :repo

      def initialize(repo)
        @repo = repo
      end

      def self.install(*args)
        new(*args).install
      end

      def install
        return unless url.present?
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
          events: events,
          active: true,
          config: {
            url: url,
            content_type: 'json',
            secret: Shipr.configuration.auth_token
          } }
      end

      def events
      end

      def name
        :web
      end

      def client
        Shipr.github
      end
    end
  end
end
