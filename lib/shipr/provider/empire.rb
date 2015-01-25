module Shipr::Provider
  class Empire < Base
    attr_reader :empire_client, :registry

    def initialize(empire_client, registry)
      @empire_client = empire_client
      @registry = registry
    end

    def start(job)
      image_id = registry.resolve_tag(job.repo.name, job.sha)
      empire_client.create_deploy id: image_id, repo: job.repo.name
    end

    class EmpireClient
      attr_reader :url

      def initialize(url)
        @url = url
      end

      def create_deploy(image)
        connection.post '/v1/deploys', image: image
      end

      private

      def connection
        @connection ||= Faraday.new(url) do |builder|
          builder.request :json
          builder.response :json
          builder.adapter Faraday.default_adapter
        end
      end
    end

    class RegistryClient
      attr_reader :url, :auth

      def initialize(url, auth)
        @url = url || 'https://registry.hub.docker.com'
        @auth = auth
      end

      def resolve_tag(repo, tag)
        resp = connection.get "/v1/repositories/#{repo}/tags/#{tag}"
        resp.body.gsub(/^"(.*)"/, '\\1')
      end

      private

      def connection
        @connection ||= Faraday.new(url) do |builder|
          builder.request :json
          builder.adapter Faraday.default_adapter
        end.tap do |connection|
          connection.basic_auth(*auth.split(':'))
        end
      end
    end
  end
end
