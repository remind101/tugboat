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
    end
  end
end
