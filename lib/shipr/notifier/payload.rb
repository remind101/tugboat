module Shipr::Notifier
  class Payload
    include Virtus.model

    def self.new_from_github(params)
      new \
        name:        params.repository.name,
        user:        params.deployment.payload.user,
        sha:         params.deployment.sha,
        target_url:  params.deployment_status.target_url,
        environment: params.deployment.environment,
        state:       params.deployment_status.state
    end

    attribute :name,        String
    attribute :user,        String
    attribute :target_url,  String
    attribute :sha,         String
    attribute :environment, String
    attribute :state,       Symbol

    def short_sha
      @short_sha ||= sha[0..5]
    end
  end
end
