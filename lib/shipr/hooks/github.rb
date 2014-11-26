module Shipr
  module Hooks
    class GitHub < Grape::API
      logger Shipr.logger

      format :json
      default_format :json

      represent Shipr::Job, with: Entities::Job

      helpers do
        delegate :deployments_service, :notifier, to: :Shipr

        def event
          ActiveSupport::StringInquirer.new(headers['X-Github-Event'])
        end
      end

      helpers do
        delegate :authenticate!, to: :warden

        def warden; env['warden'] end
      end

      before do
        authenticate!(scope: :api)
      end

      post do
        status 200
        if event.deployment?
          job = deployments_service.create(
            params.repository.full_name,
            sha:         params.deployment.sha,
            guid:        params.deployment.id,
            force:       params.deployment.payload.try(:force),
            environment: params.deployment.environment,
            config:      params.deployment.payload.try(:config),
            description: params.deployment.description
          )
          present job
        elsif event.deployment_status?
          notifier.notify Shipr::Notifier::Payload.new_from_github params
          present({})
        else
          {}
        end
      end
    end
  end
end
