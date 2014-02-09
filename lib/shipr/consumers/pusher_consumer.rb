module Shipr
  module Consumers
    class PusherConsumer
      include Hutch::Consumer
      consume 'pusher.push'

      def process(message)
        Shipr.pusher.trigger(message[:channel], message[:event], message[:data])
      end
    end
  end
end
