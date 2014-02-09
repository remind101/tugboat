module Shipr
  module Consumers
    class OutputConsumer
      include Hutch::Consumer
      consume 'job.complete'

      def process(message)
        p message
      end
    end
  end
end
