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
        payload.payload.user
      end

      def environment
        payload.payload.environment
      end

      def name
        payload.name
      end

      def sha
        payload.sha
      end

      def short_sha
        sha[0..5]
      end

      def target_url
        payload.target_url
      end

      def state
        ActiveSupport::StringInquirer.new(payload.state)
      end
    end
  end
end
