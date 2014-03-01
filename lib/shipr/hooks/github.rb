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
        optional :description,
          type: String,
          desc: 'The description of the deploy.'
      end
      post do
        if authenticated?
          status 200
          if deployment?
            params.payload ||= Hashie::Mash.new
            attributes = {
              sha: params.sha,
              description: params.description,
              environment: params.payload.environment,
              config: params.payload.config
            }
            attributes.reject! { |k,v| v.nil? }
            present JobCreator.create params.name, attributes
          else
            {}
          end
        else
          error!('Forbidden', 403)
        end
      end
    end
  end
end
