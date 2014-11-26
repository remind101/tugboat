module Shipr
  module Notifiers
    class Base
      attr_reader :payload

      def initialize(payload)
        @payload = payload
      end

      def self.notify(*args)
        new(*args).notify
      end

    private

      def user
        deployment.payload.user
      end

      def environment
        deployment.environment
      end

      def name
        repository.name
      end

      def sha
        deployment.sha
      end

      def short_sha
        sha[0..5]
      end

      def target_url
        deployment_status.target_url
      end

      def repository
        @repository ||= payload.repository
      end
      
      def deployment
        @deployment ||= payload.deployment
      end

      def deployment_status
        @deployment_status ||= payload.deployment_status
      end

      def state
        ActiveSupport::StringInquirer.new(deployment_status.state)
      end
    end
  end
end
