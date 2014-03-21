module Shipr
  module Hooks
    class GitHub < Grape::API
      logger Shipr.logger

      format :json
      default_format :json

      helpers do
        def event
          headers['X-Github-Event']
        end

        def ping?
          event == 'ping'
        end

        def deployment?
          event == 'deployment'
        end

        def deploy
          deployment? ? GitHubJobCreator.create(params) : {}
        end
      end

      helpers do
        delegate :authenticate!, to: :warden

        def warden; env['warden'] end
      end

      before do
        authenticate!(scope: :api)
      end

      params do
        optional :id, type: Integer
        optional :sha, type: String
        optional :name, type: String
        optional :description, type: String
        group :payload do
          optional :environment, type: String
        end
      end
      post do
        status 200
        present deploy
      end
    end
  end
end
