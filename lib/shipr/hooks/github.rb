module Shipr
  module Hooks
    class GitHub < Grape::API
      logger Shipr.logger

      format :json
      default_format :json

      represent Shipr::Job, with: Entities::Job

      helpers do
        def event
          ActiveSupport::StringInquirer.new(headers['X-Github-Event'])
        end

        def deployments_service
          Shipr.deployments_service
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
            ref:         params.deployment.ref,
            guid:        params.deployment.id,
            force:       params.deployment.payload.try(:force),
            environment: params.deployment.environment,
            config:      params.deployment.payload.try(:config),
            description: params.deployment.description
          )
          present job
        else
          {}
        end
      end
    end
  end
end
