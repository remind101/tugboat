module Shipr
  module GitHub
    class Client
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def create_deployment(repo, attributes)
        connection.post "/repos/#{repo}/deployments", attributes
      end

      def update_deployment_status(repo, id, attributes)
        connection.post "/repos/#{repo}/deployments/#{id}/statuses", attributes
      end

      def create_hook(repo, attributes)
        connection.post "/repos/#{repo}/hooks", attributes
      end

      def get_hooks(repo)
        connection.get "/repos/#{repo}/hooks"
      end

      private

      def connection
        @connection ||= Faraday.new('https://api.github.com') do |builder|
          builder.request :authorization, :token, options[:token]
          builder.response :raise_error
          builder.response :json
          builder.request :json
          builder.adapter Faraday.default_adapter
        end.tap do |connection|
          connection.headers['Accept'] = 'application/vnd.github.cannonball-preview+json'
        end
      end
    end
  end
end
