module Shipr
  module Hooks
    class GitHub < Grape::API
      logger Shipr.logger

      format :json

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
      end

      helpers do
        delegate :pusher, to: :'Shipr'
        delegate :authenticated?, to: :warden

        def warden; env['warden'] end
      end

      use Warden::Manager

      params do
        requires :sha,
          type: String,
          desc: 'The sha to deploy.'
        requires :name,
          type: String,
          desc: 'The repo to deploy (<user>/<repo>).'
        optional :payload,
          type: Hash,
          desc: 'The payload (the config environment).'
      end
      post do
        if authenticated?
          if deployment?
            params.payload ||= { config: {}, notify: [] }
            JobCreator.create(
              repo: "git@github.com:#{params.name}",
              branch: params.sha,
              config: params.payload.config,
              notify: params.payload.notify
            )
          end

          status 200
          {}
        else
          error!('Forbidden', 403)
        end
      end
    end
  end
end
