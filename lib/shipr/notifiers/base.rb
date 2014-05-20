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
        deployment.payload.environment
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
        payload.target_url
      end

      def repository
        @repository ||= payload.repository
      end
      
      def deployment
        @deployment ||= payload.deployment
      end

      def state
        ActiveSupport::StringInquirer.new(payload.state)
      end
    end
  end
end
